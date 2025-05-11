import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { AppStorageV2, KeyboardAvoidMode, window } from '@kit.ArkUI';
import { auth, currentBreakPoint, fullScreen, Logger, SaveContext } from 'basic';
import { deviceInfo } from '@kit.BasicServicesKit';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info('Ability onCreate')
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
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
}