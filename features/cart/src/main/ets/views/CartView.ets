import {
  auth,
  cart,
  CartGoods,
  CartGoodsModel,
  EmitterKey,
  MkDialogLoading,
  MkEmpty,
  MkNavbar,
  MkUser,
  ViewsConstants
} from 'basic'
import { promptAction } from '@kit.ArkUI'
import { emitter } from '@kit.BasicServicesKit'
import { MkGuessComp } from 'home'

@Builder
function CartViewBuilder() {
  CartView()
}

@ComponentV2
export struct CartView {
  @Local user: MkUser = auth.init().user
  // productInformation
  @Local cartList: CartGoodsModel[] = []
  @Consumer()
  navPath: NavPathStack = new NavPathStack()
  @Local
  isFullPage: boolean = false
  dialog = new CustomDialogController({
    builder: MkDialogLoading(),
    customStyle: true,
    alignment: DialogAlignment.Center,
    maskColor: '#00000000'
  })

  aboutToAppear(): void {
    this.isFullPage = !!this.navPath.getParamByName(ViewsConstants.CART_VIEW)[0]
    this.getData()
  }

  async getData() {
    // not Logged In
    if (!auth.getUser()
      .token) {
      return
    }
    this.dialog.open()
    //get default list data
    const res = await cart.getList()
    this.cartList = res.data.result.map((v: CartGoods) => new CartGoodsModel(v))
    this.dialog.close()
  }

  @Builder
  DeleteBuilder(onDelete: () => void) {
    Text('删除')
      .fontSize(14)
      .width(60)
      .height(100)
      .backgroundColor($r('[basic].color.red'))
      .fontColor($r('[basic].color.white'))
      .textAlign(TextAlign.Center)
      .onClick(() => {
        onDelete()
      })
  }

  onCheckOrder() {
    //selectAtLeastOneProduct
    if (this.cartList.some(v => v.selected)) {
      this.navPath.pushPath({ name: ViewsConstants.CHECK_VIEW })
    } else {
      promptAction.showToast({
        message: '请选择商品'
      })
    }
  }

  // getWhetherToSelectAll
  isCheckAll() {
    return this.cartList.every(v => v.selected)
  }

  totalPrice() {
    //Get the selected product first and then calculate the total price
    return this.cartList.filter(v => v.selected)
      .reduce((prev, cur) => cur.count * cur.price + prev, 0)
      .toFixed(2)
  }

  build() {
    NavDestination() {
      Column() {
        MkNavbar({
          title: '购物袋',
          showLeftIcon: this.isFullPage,
          showRightIcon: true,
          leftClickHandler: () => {
            this.navPath.pop()
          }
        })
          .border({
            width: { bottom: 0.5 },
            color: '#e4e4e4'
          })
        List() {
          if (this.user.token) {
            if (this.cartList.length) {
              ForEach(this.cartList, (item: CartGoodsModel, index: number) => {
                ListItem() {
                  CartItemComp({
                    cart: item,
                    onChangeSelected: selected => {
                      // updateTheData
                      item.selected = selected
                      // updateThePage
                      this.cartList.splice(index, 1, item)
                    },
                    onChangeCount: count => {
                      // updateTheData
                      item.count = count
                      // updateThePage
                      this.cartList.splice(index, 1, item)
                    }
                  }).onClick(()=>{
                    // go to the product details page
                    this.navPath.pushPathByName(ViewsConstants.GOODS_VIEW,item)
                  })
                }
                .backgroundColor($r('[basic].color.under'))
                .padding({ left: 8, right: 8 })
                .transition({ type: TransitionType.Delete, opacity: 0 })
                .swipeAction({
                  end: this.DeleteBuilder(async () => {
                    AlertDialog.show({
                      title: '温馨提示',
                      message: '确定删除该商品吗？',
                      buttons: [
                        {
                          value: '取消', fontColor: $r('[basic].color.gray'), action: () => {
                        }
                        },
                        {
                          value: '确定', fontColor: $r('[basic].color.black'), action: async () => {
                          this.dialog.open()
                          // Server-side deletion to delete items based on the skuId
                          await cart.remove({ ids: [item.skuId] })
                          // localDeletion
                          this.cartList.splice(index, 1)
                          // updateTheNumberOfShoppingBags
                          await cart.getCount()
                          this.dialog.close()
                        }
                        }
                      ]
                    })
                  })
                })
              }, (cart: CartGoods) => cart.skuId)
            } else {
              ListItem() {
                MkEmpty({
                  tip: '购物袋是空的',
                  buttonText: '去逛逛',
                  onClickButton: () => {
                    // go home
                    emitter.emit(EmitterKey.CHANGE_TAB, {
                      data: {
                        index: 0
                      }
                    })
                  }
                })
              }
            }
          } else {
            // notLoggedIn
            ListItem() {
              MkEmpty({
                tip: '您还未登陆美蔻',
                buttonText: '去登录',
                onClickButton: () => {
                  this.navPath.pushPath({ name: ViewsConstants.LOGIN_VIEW })
                }
              })
            }
          }
          ListItem() {
            MkGuessComp()
          }
        }
        .contentStartOffset(8)
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)

        if (this.cartList.length) {
          Row() {
            Checkbox()
              .selectedColor($r('[basic].color.red'))
              .select(this.isCheckAll())
              .onClick(async () => {
                this.dialog.open()
                //update data
                await cart.checkAll({ selected: !this.isCheckAll() })
                this.cartList.map(v => v.selected = !this.isCheckAll())
                this.cartList = [...this.cartList]
                this.dialog.close()
              })
            Text('全选')
              .fontSize(14)
              .fontColor($r('[basic].color.black'))
              .margin({ right: 20 })
            Text('合计:')
              .fontSize(14)
              .fontColor($r('[basic].color.black'))
              .margin({ right: 2 })
            Text(this.totalPrice())
              .fontSize(16)
              .fontWeight(500)
              .fontColor($r('[basic].color.red'))
              .layoutWeight(1)
            Button('去结算')
              .fontSize(14)
              .height(36)
              .backgroundColor($r('[basic].color.red'))
              .onClick(() => {
                this.onCheckOrder()
              })
          }
          .height(50)
          .width('100%')
          .backgroundColor($r('[basic].color.white'))
          .border({
            width: { top: 0.5, bottom: 0.5 },
            color: '#e4e4e4'
          })
          .padding({ left: 16, right: 16 })
        }
      }
      .height('100%')
      .width('100%')
      .backgroundColor($r('[basic].color.under'))
    }
    .hideTitleBar(true)
    .onVisibleAreaChange([0, 1], () => {
      this.getData()
    })
  }
}


@ComponentV2
struct CartItemComp {
  @Require @Param @Once cart: CartGoodsModel
  dialog = new CustomDialogController({
    builder: MkDialogLoading({ message: '' }),
    customStyle: true,
    alignment: DialogAlignment.Center,
  })
  @Event onChangeSelected: (selected: boolean) => void = () => {

  }
  @Event onChangeCount: (count: number) => void = () => {

  }

  build() {
    Row({ space: 10 }) {
      Checkbox()
        .selectedColor($r('[basic].color.red'))
        .select(this.cart.selected)
        .size({ width: 14, height: 14 })
        .onClick(async () => {
          this.dialog.open()
          // update
          // serverSide
          await cart.updateGoods(this.cart.skuId, { selected: !this.cart.selected, count: this.cart.count })
          // locallySelected
          this.cart.selected = !this.cart.selected
          this.dialog.close()
          // notifyTheParentComponentOfTheUpdate
          this.onChangeSelected(this.cart.selected)
        })
      Image(this.cart.picture)
        .width(80)
        .height(80)
      Column({ space: 8 }) {
        Text(this.cart.name)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .fontSize(14)
          .fontColor($r('[basic].color.black'))
          .width('100%')
        Row() {
          Text(this.cart.attrsText)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .fontSize(12)
            .fontColor($r('[basic].color.text'))
            .layoutWeight(1)
          Image($r('sys.media.ohos_ic_public_arrow_down'))
            .fillColor($r('[basic].color.gray'))
            .width(16)
            .height(16)
        }
        .padding({ left: 6, right: 4 })
        .width(100)
        .height(24)
        .backgroundColor($r('[basic].color.under'))
        .borderRadius(2)

        Row() {
          Text(`¥${this.cart.price}`)
            .fontSize(14)
            .fontWeight(500)
          Counter() {
            Text(this.cart.count.toString())
          }
          .enableDec(this.cart.count > 1)
          .onDec(async () => {
            this.dialog.open()
            // update
            // serverside
            await cart.updateGoods(this.cart.skuId, { selected: this.cart.selected, count: this.cart.count - 1 })
            this.cart.count--
            // shoppingBag
            cart.getCount()
            // notifyTheParentComponentOfTheUpdate
            this.onChangeCount(this.cart.count)
            this.dialog.close()
          })
          .onInc(async () => {
            this.dialog.open()
            // update
            // serverside
            await cart.updateGoods(this.cart.skuId, { selected: this.cart.selected, count: this.cart.count + 1 })
            // local
            this.cart.count++
            // shoppingBag
            cart.getCount()
            // notifyTheParentComponentOfTheUpdate
            this.onChangeCount(this.cart.count)
            this.dialog.close()
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(100)
    .padding(10)
    .border({ width: { bottom: 0.5 }, color: '#e4e4e4' })
    .backgroundColor($r('[basic].color.white'))
  }
}