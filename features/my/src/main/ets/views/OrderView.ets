import { fullScreen, MkDialogLoading, MkEmpty, MkNavbar, MkTabs, ViewsConstants } from 'basic'
import { OrderItem, OrderSku } from '../viewmodel'
import { promptAction, router } from '@kit.ArkUI'
import { consignmentApi, getOrderApi } from '../apis'
import { GoodsItemsDataSource } from 'home/src/main/ets/viewmodel/lazyForeach'
import { deviceInfo } from '@kit.BasicServicesKit'

@Builder
function OrderViewBuilder() {
  OrderView()
}

// topOfTheLineComponents
@ComponentV2
export struct OrderView {
  @Local safeBottom: number = fullScreen.init().bottomArea
  @Local activeIndex: number = 0
  @Local isEmpty: boolean = false
  page: number = 1
  totalPage: number = 0
  @Consumer()
  navPath: NavPathStack = new NavPathStack()
  @Local isRefreshing: boolean = false
  dialog = new CustomDialogController({
    builder: MkDialogLoading(),
    customStyle: true,
    alignment: DialogAlignment.Center,
    maskColor: '22000000',
    autoCancel: false
  })
  @Local list: GoodsItemsDataSource<OrderItem> = new GoodsItemsDataSource()

  //getOrderListData
  async getData() {
    this.dialog.open()
    this.list.reloadData([])
    this.page = 1
    const res = await getOrderApi({
      pageSize: 5, // pageCapacity
      page: this.page, // pagination
      orderState: this.activeIndex // orderClassification
    })
    // saveTheListData
    this.list.reloadData(res.data.result.items)
    this.totalPage = res.data.result.pages
    this.isEmpty = this.list.totalCount() === 0
    this.dialog.close()
  }

  aboutToAppear(): void {
    this.activeIndex = this.navPath.getParamByName(ViewsConstants.ORDER_VIEW)[0] as number
    this.getData()
  }

  async loadMore() {
    // determineIfItStillNeedsToBeLoaded
    if (this.page < this.totalPage) {
      this.page++
      // getTheListBasedOnTheNewParameters
      const res = await getOrderApi({
        pageSize: 5,
        page: this.page,
        orderState: this.activeIndex // orderClassification
      })
      this.list.pushDataArray(res.data.result.items)
    } else {
      promptAction.showToast({ message: '没有更多数据了～' })
    }
  }

  build() {
    NavDestination() {
      Column() {
        MkNavbar({
          title: '我的订单', leftClickHandler: () => {
            this.navPath.pop()
          }, bg: $r('[basic].color.under')
        })
        Row() {
          MkTabs({
            activeIndex: this.activeIndex,
            tabConfig: [
              { name: '全部' },
              { name: '待付款' },
              { name: '待发货' },
              { name: '待收货' },
              { name: '待评价' }
            ],
            spaceBetween: true,
            onTabChange: (_item, index) => {
              this.activeIndex = index
              this.getData()
            }
          })
        }
        .height(40)

        if (this.isEmpty) {
          MkEmpty({
            tip: '空空如也',
            buttonText: '去逛逛',
            onClickButton: () => {
              this.navPath.pop();
            }
          })
        }
        //listOfOrders
        Refresh({ refreshing: $$this.isRefreshing }) {
          Column() {
            List() {
              LazyForEach(this.list, (order: OrderItem) => {
                ListItem() {
                  OrderItemComp({ order })
                }
              })
            }
            .width('100%')
            .height('100%')
            .margin(8)
            .divider({
              strokeWidth: 8,
              color: $r('[basic].color.under')
            })
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.None)
            .onReachEnd(() => {
              this.loadMore()
            })
          }.height('100%')
        }
        .onRefreshing(async () => {
          this.isRefreshing = false
          promptAction.showToast({ message: '刷新成功', alignment: Alignment.Top, offset: { dy: 200, dx: 0 } })
        })
      }.height('100%')
      .backgroundColor($r('[basic].color.under'))
    }
    .hideTitleBar(true)

  }
}

// listItems
@ComponentV2
struct OrderItemComp {
  @Require @Param order: OrderItem
  timer: number = 0
  @Local countDown: string = ''
  @Local totalTime: number = 0

  formatTime(time: number) {
    const h = Math.floor(time / 3600).toString() //hour
    const m = Math.floor((time % 3600) / 60).toString() //minute
    const s = Math.floor(time % 60).toString() //second
    return `${h.padStart(2, '0')}:${m.padStart(2, '0')}:${s.padStart(2, '0')}}`
  }

  startCountDown() {
    this.totalTime = this.order.countdown
    //format to hh:mm:ss
    this.countDown = this.formatTime(this.totalTime)
    //Determine if the order status is pending and the countdown times out
    if (this.order.orderState === 1 && this.totalTime === -1) {
      this.order.orderState = 6
      return
    }
    //theCountdownDidNotTimeOut
    if (this.order.orderState === 1 && this.totalTime > -1) {
      this.timer = setInterval(() => {
        this.totalTime--
        //format
        this.countDown = this.formatTime(this.totalTime)
        //whetherTheCountdownIsOver
        if (this.totalTime <= 0) {
          clearInterval(this.timer)
          //  order status is canceled
          this.order.orderState = 6
        }
      }, 1000)
    }
  }

  aboutToAppear(): void {
    this.startCountDown()
  }

  aboutToDisappear(): void {
    clearInterval(this.timer)
  }

  @Builder
  StateBuilder() {
    if (this.order.orderState === 1) {
      Row() {
        Text('待付款')
          .textAlign(TextAlign.Center)
          .width(50)
          .fontColor($r('[basic].color.white'))
          .fontSize(11)
          .height(18)
          .borderRadius({ bottomRight: 9 })
          .linearGradient({
            angle: 90,
            colors: [[$r('[basic].color.linear_begin'), 0], [$r('[basic].color.linear_end'), 1]]
          })
        Text(this.countDown)
          .textAlign(TextAlign.Center)
          .width(60)
          .fontSize(11)
          .fontColor($r('[basic].color.red'))
      }
      .backgroundColor('#FFDEE2')
      .height(18)
      .borderRadius(9)
      .clip(true)
    } else if (this.order.orderState === 2) {
      Text('待发货')
        .fontSize(12)
        .fontColor($r('[basic].color.red'))
    } else if (this.order.orderState === 3) {
      Text('待收货')
        .fontSize(12)
        .fontColor($r('[basic].color.red'))
    } else if (this.order.orderState === 4) {
      Text('待评价')
        .fontSize(12)
        .fontColor($r('[basic].color.black'))
    } else if (this.order.orderState === 5) {
      Text('已完成')
        .fontSize(12)
        .fontColor($r('[basic].color.black'))
    } else if (this.order.orderState === 6) {
      Text('已取消')
        .fontSize(12)
        .fontColor($r('[basic].color.gray'))
    }
  }

  @Builder
  ButtonBuilder() {
    Row({ space: 10 }) {
      if ([5, 6].includes(this.order.orderState)) {
        Button('删除订单')
          .whiteStyle()
          .onClick(() => {
            // TODO
          })
      }
      if ([5].includes(this.order.orderState)) {
        Button('查看评价')
          .whiteStyle()
          .onClick(() => {
            // TODO
          })
      }
      if ([3, 4, 5].includes(this.order.orderState)) {
        Button('查看物流')
          .whiteStyle()
          .onClick(() => {
            router.pushUrl({ url: 'pages/OrderLogisticsPage' })
          })
      }
      if ([1].includes(this.order.orderState)) {
        Button('取消订单')
          .whiteStyle()
          .onClick(() => {
            // TODO
          })
      }
      if ([1].includes(this.order.orderState)) {
        Button('立即付款')
          .redStyle()
          .onClick(() => {
            // TODO
          })
      }
      // Determine the order status and whether it is a simulator
      if ([2].includes(this.order.orderState) && deviceInfo.marketName === 'emulator') {
        Button('模拟发货').height(30)
          .onClick(async () => {
            await consignmentApi(this.order.id)
            promptAction.showToast({ message: '模拟发货～' })
            this.order.orderState = 3
          })
      }
      if ([2, 5, 6].includes(this.order.orderState)) {
        Button('再次购买')
          .redStyle()
          .onClick(() => {
            // TODO
          })
      }
      if ([3].includes(this.order.orderState)) {
        Button('确认收货')
          .redStyle()
          .onClick(() => {
            // TODO
          })
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.End)
  }

  build() {
    Row() {
      Column() {
        Row() {
          Text(this.order.createTime)
            .fontSize(12)
            .fontColor($r('[basic].color.gray'))
          this.StateBuilder()
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        ForEach(this.order.skus, (sku: OrderSku) => {
          OrderSkuComp({ goods: sku })
        })

        Text('实付款：¥' + this.order.payMoney)
          .fontWeight(500)
          .fontColor($r('[basic].color.black'))
          .alignSelf(ItemAlign.End)
          .padding({ top: 10, bottom: 10 })

        this.ButtonBuilder()
      }
      .padding(10)
      .borderRadius(8)
      .backgroundColor($r('[basic].color.white'))
    }
    .padding({ left: 8, right: 8 })
  }
}

// orderInformation
@ComponentV2
struct OrderSkuComp {
  @Require @Param goods: OrderSku

  build() {
    Row({ space: 10 }) {
      Image(this.goods.image)
        .width(80)
        .height(80)
      Column({ space: 10 }) {
        Text(this.goods.name)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontColor($r('[basic].color.black'))
          .fontSize(14)
          .width('100%')
        Text(this.goods.attrsText)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .fontColor($r('[basic].color.text'))
          .fontSize(14)
      }
      .justifyContent(FlexAlign.Start)
      .layoutWeight(1)
      .height(80)

      Column({ space: 10 }) {
        Text('¥' + this.goods.curPrice)
          .fontSize(14)
          .fontColor($r('[basic].color.black'))
        Text('x' + this.goods.quantity)
          .fontSize(14)
          .fontColor($r('[basic].color.gray'))
      }
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.End)
      .width(70)
      .height(80)
    }
    .padding({ top: 10, bottom: 10 })
  }
}


@Extend(Button)
function whiteStyle() {
  .fontWeight(400)
  .fontSize(14)
  .height(30)
  .backgroundColor($r('[basic].color.white'))
  .fontColor($r('[basic].color.black'))
  .padding({
    left: 10,
    right: 10,
    top: 0,
    bottom: 0
  })
  .border({ width: 0.5, color: $r('[basic].color.border') })
}

@Extend(Button)
function redStyle() {
  .fontWeight(400)
  .fontSize(14)
  .height(30)
  .padding({
    left: 10,
    right: 10,
    top: 0,
    bottom: 0
  })
  .backgroundColor($r('[basic].color.red'))
}

