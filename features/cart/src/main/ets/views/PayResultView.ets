import { MkGuess, MkNavbar, ViewsConstants } from 'basic'
import { MkGuessComp } from 'home'


@Builder
function PayResultViewBuilder() {
  PayResultView()
}

@ComponentV2
export struct PayResultView {
  @Param payResult: boolean = false
  @Param orderId: string = ''
  @Consumer() navPath: NavPathStack = new NavPathStack()

  aboutToAppear(): void {

  }

  build() {
    NavDestination() {
      Column() {
        MkNavbar({ title: this.payResult ? '付款成功' : '付款失败' })
        List() {
          ListItem() {
            Column({ space: 20 }) {
              Image(this.payResult ? $r('[basic].media.ic_public_check_filled') :
              $r('[basic].media.ic_public_close_filled'))
                .width(60)
                .height(60)
                .fillColor(this.payResult ? '#00C1BF' : '#B0171F')
              Text(this.payResult ? '付款成功' : '付款失败')
              Row({ space: 20 }) {
                Button('返回首页')
                  .backgroundColor($r('[basic].color.black'))
                  .fontSize(14)
                  .height(36)
                  .onClick(() => {
                    this.navPath.popToIndex(-1)
                    // clearThePageStack
                    this.navPath.clear()
                  })
                Button('查看订单')
                  .fontSize(14)
                  .height(36)
                  .backgroundColor($r('[basic].color.white'))
                  .fontColor($r('[basic].color.black'))
                  .border({ width: 0.5, color: $r('[basic].color.border') })
                  .onClick(() => {
                    this.navPath.pushPathByName(ViewsConstants.ORDER_VIEW, this.orderId)
                  })

              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
            }
            .padding(40)
            .backgroundColor($r('[basic].color.under'))
          }

          ListItem() {
            MkGuessComp()
          }
        }
        .layoutWeight(1)
        .height('100%')
        .width('100%')
        .scrollBar(BarState.Off)
      }
    }
    .hideTitleBar(true)
  }
}