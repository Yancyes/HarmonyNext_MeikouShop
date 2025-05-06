import { HmSku, Sku } from '@ohmos/sku'
import { auth, cart, MKDialogLoading, MkGoodsItem, MkNavbar, SafeAreaConstants, ViewsConstants } from 'basic'
import { Goods } from '../viewmodel'
import { promptAction, window } from '@kit.ArkUI'
import { getGoodsApi } from '../api'
import { MkGuessComp } from '../components/MkWaterFlow'
import { GoodsItemsDataSource } from '../viewmodel/lazyForeach'


@Builder
function GoodsViewBuilder() {
  NavDestination() {
    GoodsView()
  }
  .hideTitleBar(true)
}


@ComponentV2
export struct GoodsView {
  safeBottom: number = AppStorage.get(SafeAreaConstants.BOTTOM) as number
  @Local goods: Goods = {} as Goods
  @Local activeIndex: number = 0
  @Local showSheet: boolean = false
  @Local count: number = 1
  @Local loading: boolean = false
  @Local sku: HmSku = {} as HmSku
  @Local likeGoods: GoodsItemsDataSource<MkGoodsItem> = new GoodsItemsDataSource()
  scroller = new Scroller()
  @Consumer() navPath: NavPathStack = new NavPathStack()
  dialog = new CustomDialogController({
    builder: MKDialogLoading({ message: '拼命加载中', }),
    customStyle: true
  })
  tabs: string[] = ['商品', '评价', '详情', '推荐']
  @Local cartCount:number = cart.init().count
  setStatusBar() {
    window.getLastWindow(getContext())
      .then((win) => {
        win.setWindowSystemBarProperties({ statusBarContentColor: '#000000' })
      })
  }

  async aboutToAppear() {
    //get router Params
    this.goods = this.navPath.getParamByName(ViewsConstants.GOODS_VIEW).pop() as Goods
    //loading detailPage Data
    this.getData()
    this.setStatusBar()

  }

  async getData() {
    this.dialog.open()
    const res = await getGoodsApi(this.goods.id)
    this.goods = res.data.result
    this.dialog.close()
  }

  @Builder
  CustomTitleBuilder() {
    Row({ space: 10 }) {
      ForEach(this.tabs, (item: string, index: number) => {
        Text(item)
          .fontColor(this.activeIndex === index ? $r('[basic].color.black') : $r('[basic].color.gray'))
          .onClick(() => {
            // setTheHighlightSubscript
            this.activeIndex = index
            // setsTheScrollPositionOfTheListComponent
            animateTo({ duration: 200 }, () => {
              this.scroller.scrollToIndex(index)
            })
          })
      })
    }

    Blank()
    // floorSwitching
    Image($r('[basic].media.ic_public_shared'))
      .iconButton()
  }

  @Builder
  AddCartBuilder() {
    Column() {
      Text('已选: ' + (this.sku.specsText || ''))
        .fontWeight(300)
        .width('100%')
        .fontColor($r('[basic].color.black'))
        .fontSize(14)
        .padding({ bottom: 10, right: 50 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Row({ space: 10 }) {
        Image(this.sku.picture || this.goods.mainPictures?.[0])
          .alt($r('app.media.ic_sku_img'))
          .width(80)
          .height(80)
          .backgroundColor($r('[basic].color.under'))
          .borderRadius(4)
        Column() {
          Row() {
            Text('现价¥')
              .fontSize(14)
              .fontColor($r('[basic].color.black'))
              .offset({ y: -4 })
            Text(this.sku.price || this.goods.price)
              .fontSize(24)
              .fontColor($r('[basic].color.black'))
              .fontWeight(500)
            Text('原价¥' + (this.sku.oldPrice || this.goods.price))
              .fontSize(12)
              .fontColor($r('[basic].color.gray'))
              .margin({ left: 10 })
              .offset({ y: -4 })
              .decoration({
                type: TextDecorationType.LineThrough,
                color: $r('[basic].color.gray')
              })
          }
          .alignItems(VerticalAlign.Bottom)

          Row({ space: 10 }) {
            Counter() {
              Text(this.count.toString())
            }
            .enableInc(this.count < (this.sku.inventory || this.goods.inventory)) // addLessThanTheInventoryCanAlsoBeAdded
            .enableDec(this.count > 1) // minusMoreThan1CanAlsoBeReduced
            .onInc(() => {
              this.count++
            })
            .onDec(() => {
              this.count--
            })

            Text(`库存充足` + (this.sku.inventory || this.goods.inventory))
              .fontSize(12)
              .fontColor($r('[basic].color.gray'))
          }
        }
        .height(80)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      Divider()
        .strokeWidth(4)
        .color($r('[basic].color.under'))
        .margin({ left: -8, right: -8, top: 13 })

      List() {
        ListItem() {
          //Sku comp
          Sku({
            specs: this.goods.specs,
            skus: this.goods.skus,
            onSkuChange: (sku: HmSku) => {
              this.sku = sku
            }
          })
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      Row() {
        Button(this.loading ? '加入中...' : '加入购物袋')
          .buyButton($r('[basic].color.black'), true)
          .onClick(() => {
            this.addToCart()
          })
        Button('立即购买')
          .buyButton($r('[basic].color.red'), false)
      }
      .width('100%')
    }
    .height(600)
    .padding({
      left: 16,
      right: 16,
      top: 16,
      bottom: this.safeBottom || 16
    })
  }

  async addToCart() {
    const token = auth.getUser().token
    if(!token){
      promptAction.showToast({message:'请登录后下单'})
      this.navPath.pushPath({name:ViewsConstants.LOGIN_VIEW})
      return
    }
    //Determine whether the user has a product selection rule
    if(!this.sku.id){
      promptAction.showToast({message:'请选择要购买的商品规格'})
      return
    }
    //addToCart
    this.loading = true
    await cart.add({skuId:this.sku.id,count:this.count})
    this.loading = false
    promptAction.showToast({message:'加入购物袋成功'})
    //close sheet
    this.showSheet = false
    //updateCartCount
    cart.getCount()
  }
  build() {
    Column() {
      MkNavbar({
        showRightIcon: true,
        customTitle: () => {
          this.CustomTitleBuilder()
        },
        leftClickHandler: () => {
          this.navPath.pop()
        }
      })
      Column() {
        List({ scroller: this.scroller }) {
          ListItem() {
            // productInformation
            GoodsInfoComp({
              goods: this.goods, showSheet: (isShow: boolean) => {
                this.showSheet = isShow
              }
            })
          }

          ListItem() {
            // reviewsThereAreCurrentlyNoReviewData
            GoodsCommentComp({ goods: this.goods })
          }

          ListItem() {
            // productDetails
            GoodsDetailComp({ goods: this.goods })
          }

          ListItem() {
            // youMayAlsoLikeIt
            MkGuessComp()
          }
        }
        .onScrollIndex((index) => {
          this.activeIndex = index
        })
        .scrollBar(BarState.Off)
        .width('100%')
        .height('100%')
      }
      .layoutWeight(1)
      .backgroundColor($r('[basic].color.under'))

      Row() {
        Image($r('[basic].media.ic_public_like'))
          .iconButton()
        Image($r('[basic].media.ic_public_comment'))
          .iconButton()
        Badge({
          count: this.cartCount,
          style: {},
          position: { x: 30, y: 4 }
        }) {
          Image($r('[basic].media.ic_public_cart'))
            .iconButton()
            .onClick(() => {
              this.navPath.pushPathByName(ViewsConstants.CART_VIEW,true )
            })
        }

        Row() {
          Button('加入购物袋')
            .buyButton($r('[basic].color.black'), true)
            .onClick(() => this.showSheet = true)
          Button('立即购买')
            .buyButton($r('[basic].color.red'), false)
            .onClick(() => {
              this.showSheet = true
            })
        }
        .layoutWeight(1)
        .padding({ right: 16, left: 6 })
      }
      .height(54)
      .width('100%')
      .margin({ bottom: this.safeBottom })
    }
    .height('100%')
    .bindSheet($$this.showSheet, this.AddCartBuilder(),
      { height: SheetSize.FIT_CONTENT, backgroundColor: $r('[basic].color.white') })
  }
}

@Extend(Image)
function iconButton() {
  .width(24)
  .aspectRatio(1)
  .margin(13)
  .fillColor($r('[basic].color.black'))
}

@Extend(Button)
function buyButton(color: ResourceStr, isLeft: boolean) {
  .fontSize(14)
  .height(36)
  .type(ButtonType.Normal)
  .layoutWeight(1)
  .backgroundColor(color)
  .borderRadius({
    topLeft: isLeft ? 18 : 0,
    bottomLeft: isLeft ? 18 : 0,
    topRight: isLeft ? 0 : 18,
    bottomRight: isLeft ? 0 : 18
  })
  .pixelRound({
    end: PixelRoundCalcPolicy.FORCE_CEIL,
    start: PixelRoundCalcPolicy.FORCE_FLOOR
  })
}

@ComponentV2
struct GoodsInfoComp {
  @Param goods: Goods = {} as Goods
  @Event showSheet: (isShow: boolean) => void

  build() {
    Column() {
      // thereAreMultipleImagesShowingTheCarousel
      if (this.goods.mainPictures && this.goods.mainPictures.length) {
        Swiper() {
          ForEach(this.goods.mainPictures, (src: string) => {
            Image(src)
          })
        }
        .cachedCount(5)
        .indicator(Indicator.digit()
          .right(10)
          .bottom(6))
        .width('100%')
        .aspectRatio(1)
      } else {
        // theMainImageIsNotShown
        Image(this.goods.picture)
          .width('100%')
          .aspectRatio(1)
      }

      Column() {
        Text() {
          Span('¥ ')
          Span(this.goods.price)
            .fontSize(24)
        }
        .width('100%')
        .fontWeight(500)
        .fontColor($r('[basic].color.black'))
        .margin({ bottom: 8, top: 8 })

        Text(this.goods.name)
          .width('100%')
          .fontColor($r('[basic].color.text'))
          .margin({ bottom: 8 })
        Text(this.goods.desc)
          .fontSize(13)
          .width('100%')
          .fontColor($r('[basic].color.gray'))
          .margin({ bottom: 8 })

        Column() {
          Row({ space: 8 }) {
            Text('商品规格')
              .fontSize(13)
              .fontWeight(500)
              .fontColor($r('[basic].color.black'))
            Text('请选择')
              .fontSize(13)
              .fontColor($r('[basic].color.gray'))
            Blank()
            Image($r('[basic].media.ic_public_right'))
              .width(20)
              .aspectRatio(1)
              .fillColor($r('[basic].color.gray'))
          }
          .width('100%')
          .height(40)
          .onClick(() => this.showSheet(true))

          Row() {
            Text('无忧退货 · 快速退款 · 免费包邮')
              .fontColor($r('[basic].color.text'))
              .fontSize(13)
            Blank()
            Image($r('[basic].media.ic_public_right'))
              .width(20)
              .aspectRatio(1)
              .fillColor($r('[basic].color.gray'))
          }
          .width('100%')
          .height(40)
          .border({
            width: { top: 0.5 },
            color: $r('[basic].color.under')
          })
        }
      }
      .backgroundColor($r('[basic].color.white'))
      .borderRadius(8)
      .margin(8)
      .padding(8)
    }
  }
}

@ComponentV2
struct GoodsCommentComp {
  @Param goods: MkGoodsItem = {} as MkGoodsItem

  build() {
    Column() {
      Row() {
        Text('商品评价')
          .fontSize(13)
          .fontWeight(700)
          .fontColor($r('[basic].color.black'))
          .margin({ right: 8 })
        Text('(100+)')
          .fontSize(13)
          .fontColor($r('[basic].color.gray'))
        Blank()
        Text('查看全部')
          .fontSize(13)
          .fontColor($r('[basic].color.gray'))
        Image($r('[basic].media.ic_public_right'))
          .width(20)
          .aspectRatio(1)
          .fillColor($r('[basic].color.gray'))
      }
      .width('100%')
      .height(40)

      ForEach(new Array(2).fill(0), () => {
        Column({ space: 8 }) {
          Row() {
            Image($r('app.media.goods_avatar'))
              .width(24)
              .aspectRatio(1)
              .margin({ right: 8 })
            Text('匿名用户1259')
              .fontColor($r('[basic].color.black'))
              .fontSize(14)
          }
          .width('100%')

          Row() {
            Text('黑色·公开版·128G')
              .fontColor($r('[basic].color.gray'))
              .fontSize(12)
            Blank()
            Text('昨天23.45')
              .fontColor($r('[basic].color.gray'))
              .fontSize(12)
          }
          .width('100%')

          Text('HUAWEI Pura 70 Ultra 创新性采用超聚光伸缩主摄，搭载1英寸大底传感器、以及1英寸传感器中最大的F1.6物理光圈，带来业界最大的主摄进光量。')
            .fontColor($r('[basic].color.text'))
            .fontSize(13)

          Row({ space: 8 }) {
            ForEach(new Array(3).fill(0), () => {
              Image(this.goods.picture)
                .width(80)
                .aspectRatio(1)
            })
          }
          .width('100%')
        }
        .margin({ top: 16 })
      })
    }
    .backgroundColor($r('[basic].color.white'))
    .borderRadius(8)
    .margin({ left: 8, right: 8, bottom: 8 })
    .padding(8)
  }
}

@ComponentV2
struct GoodsDetailComp {
  @Param goods: Goods = {} as Goods

  build() {
    Column() {
      Row() {
        Text('商品详情')
          .fontSize(13)
          .fontWeight(700)
          .fontColor($r('[basic].color.black'))
          .margin({ left: 16 })
      }
      .width('100%')
      .height(50)

      ForEach(this.goods.details?.pictures, (src: string) => {
        Image(src)
          .width('100%')
      })
    }
    .backgroundColor($r('[basic].color.white'))
    .margin({ bottom: 8 })
  }
}