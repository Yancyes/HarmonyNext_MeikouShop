import { AppStorageV2, PersistenceV2, window } from '@kit.ArkUI'
import { SaveContext } from '..'

@ObservedV2
export class FullScreen {
  @Trace topArea: number = 0
  @Trace bottomArea: number = 0

  getWindow() {
    const ctx = AppStorageV2.connect(SaveContext)!.ctx
    return window.getLastWindow(ctx)
  }

  init() {
    return PersistenceV2.connect(FullScreen, () => new FullScreen())!
  }

  async open() {
    const win = await this.getWindow()
    win.setWindowLayoutFullScreen(true)
    this.topArea = px2vp(win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect.height)
    this.bottomArea = px2vp(win.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR).bottomRect.height)
  }
}


export const fullScreen = new FullScreen()