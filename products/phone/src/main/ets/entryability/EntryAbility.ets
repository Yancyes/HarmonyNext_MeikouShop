import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { AppStorageV2, KeyboardAvoidMode, window } from '@kit.ArkUI';
import {
  auth,
  currentBreakPoint,
  fullScreen,
  getGuessLikeApi,
  guessLike,
  LoadImageForFormData,
  Logger,
  MkNavPathStack,
  SaveContext
} from 'basic';
import { deviceInfo } from '@kit.BasicServicesKit';
import rpc from '@ohos.rpc';
import { formBindingData, formProvider } from '@kit.FormKit';

// theTypeOfCallEventForCardCommunication
class Params implements rpc.Parcelable {
  marshalling(dataOut: rpc.MessageSequence): boolean {
    return true
  }

  unmarshalling(dataIn: rpc.MessageSequence): boolean {
    return true
  }
}

export default class EntryAbility extends UIAbility {
  private targetPage: string = ''

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info('Ability onCreate')
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    //save Path
    if (want.parameters?.targetPage) {
      this.targetPage = want.parameters.targetPage as string
    }

    // refreshTheCardImageData
    this.callee.on('RefreshImgList', (data: rpc.MessageSequence) => {
      // extractDataData
      const dataObj = JSON.parse(data.readString()) as Record<string, string>
      // getGuessTheDataYouLike
      getGuessLikeApi()
        .then((res) => {
          const list = res.data.result.items
          guessLike.init().items = list

          // To update the image of the card, you need to download it to your local computer first
          const imageList = list.map(item => item.picture as string)
            .slice(0, 2)
          // downloadTheImage
          const download = new LoadImageForFormData(
            this.context,
            imageList,
            (formInfo: formBindingData.FormBindingData) => {
              // Update the data associated with the card and refresh the image of the card based on the ID
              formProvider.updateForm(dataObj.formId, formInfo)
            }
          )
          download.startLoad()
        })
      return new Params()
    })
  }

  onDestroy(): void {
    Logger.info('Ability onDestroy')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    Logger.info('Ability onWindowStageCreate')
    AppStorageV2.connect(SaveContext, () => new SaveContext(this.context))!
    const win = windowStage.getMainWindowSync()
    //fullScreenIsNotRequiredInPCMode
    if (deviceInfo.deviceType !== '2in1') {
      fullScreen.init().open()
    }

    //gets The WindowSize When The App is Launched
    currentBreakPoint.updateBreakPoint(win.getWindowProperties().windowRect.width)
    //listen For WindowSize Changes
    win.on("windowSizeChange", (windowSize) => {
      currentBreakPoint.updateBreakPoint(windowSize.width)
    })
    windowStage.loadContent('pages/Index', () => {
      //set keyboard avoid mode compress
      windowStage.getMainWindowSync().getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE)
      //persistentLoginInformation
      auth.init()
      //ifThereIsATargetPageJumpToIt
      if (this.targetPage) {
        MkNavPathStack.pushPath({ name: this.targetPage })
      }
    })
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    Logger.info('Ability onWindowStageDestroy')
  }

  onForeground(): void {
    // Ability has brought to foreground
    Logger.info('Ability onForeground')
  }

  onBackground(): void {
    // Ability has back to background
    Logger.info('Ability onBackground')
  }

  onNewWant(want: Want): void {
    Logger.info('Ability onNewWant')
    Logger.info(want)
    if (want.parameters?.targetPage) {
      MkNavPathStack.pushPath({ name: want.parameters.targetPage as string })
      // routeInterception
      MkNavPathStack.setInterception({
        ///callbackBeforePageJumping
        willShow: (from: NavDestinationContext | "navBar", to: NavDestinationContext | "navBar") => {
          //excludeStrings
          if (from !== "navBar" && to !== "navBar") {
            //If it's the same page, go back to the previous page
            if ((from).pathInfo.name === (to).pathInfo.name) {
              MkNavPathStack.pop()
            }
          }
        }
      })
    }
  }
}