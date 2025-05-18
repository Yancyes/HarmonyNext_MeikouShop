import { baseURL, fullScreen, Logger, MkNavbar, MkNavPathStack, ViewsConstants } from 'basic'
import { webview } from '@kit.ArkWeb'

@Builder
function PayViewBuilder() {
  PayView()
}

@ComponentV2
export struct PayView {
  @Local orderId: string = ''
  webviewController: webview.WebviewController = new webview.WebviewController()
  @Local safeTop: number = fullScreen.init().topArea
  @Consumer() navPath: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    this.orderId = this.navPath.getParamByName(ViewsConstants.PAY_VIEW)[0] as string
  }

  showDialog() {
    AlertDialog.show({
      title: '温馨提示',
      message: '您确定要放弃支付吗？',
      buttons: [
        {
          value: '取消', action: () => {}
        },
        {
          value: '放弃支付', fontColor: $r('[basic].color.gray'),
          action: () => {
            MkNavPathStack.pop()
          }
        }
      ]
    })
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        Column() {
          if (this.orderId) {
            Web({
              src: `${baseURL}pay/wap/alipay?orderId=${this.orderId}`,
              controller: this.webviewController
            }).onPageBegin((event) => {
              Logger.info(event)
              //Check whether the URL path is the page where the payment was completed
              if (event.url.includes('/pay/redirect?')) {
                const search = event.url.split('?')[1]
                //replaceWithThePaymentResultsPage
                MkNavPathStack.replacePathByName(ViewsConstants.PAY_RESULT_VIEW, search)
              }
            })
          }
        }
        .height('100%')
        .padding({ top: this.safeTop })

        // title bar
        MkNavbar({
          title: '支付中',
          leftClickHandler:()=>{
            this.showDialog()
          }
        })
      }
      .height('100%')
    }
    .hideTitleBar(true)
    .onBackPressed(()=>{//systemLevel
      this.showDialog()
      return true
    })
  }
}