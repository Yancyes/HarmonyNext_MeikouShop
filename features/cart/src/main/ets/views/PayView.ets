import { baseURL, fullScreen, MkNavbar, ViewsConstants } from 'basic'
import { webview } from '@kit.ArkWeb'

@Builder
function PayViewBuilder() {
  PayView()
}

@ComponentV2
export struct PayView {
  orderId: string = ''
  webviewController: webview.WebviewController = new webview.WebviewController()
  @Local safeTop: number = fullScreen.init().topArea
  @Consumer() navPath: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    this.orderId = this.navPath.getParamByName(ViewsConstants.PAY_VIEW)[0] as string
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        Column() {
          if (this.orderId) {
            Web({
              src: `${baseURL}pay/wap/alipay?orderId=${this.orderId}`,
              controller: this.webviewController
            })

          }
        }
        .height('100%')
        .padding({ top: this.safeTop })

        // title bar
        MkNavbar({
          title: '支付中',
        })
      }
      .height('100%')
    }
    .hideTitleBar(true)

  }
}