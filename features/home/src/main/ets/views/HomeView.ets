import {
  Banner,
  BreakPointConstants,
  BreakPointType,
  CategoryItem,
  HotResult,
  MkGoodsItem,
  MkLoading,
  Params,
  SafeAreaConstants,
  ViewsConstants
} from 'basic'
import {
  getBannerAPI,
  getCategoryAPI,
  getHotInVogueAPI,
  getHotOneStopAPI,
  getHotPreferenceAPI,
  getNewAPI,
  getRecommendAPI
} from '../api'
import { DiscountGoodsComp, DiscountType } from '../components/DiscountGoodsComp'
import { promptAction } from '@kit.ArkUI'
import { GoodsItemsDataSource } from '../viewmodel/lazyForeach'
import { MkWaterFlow } from '../components'


@ComponentV2
export struct HomeView {
  // carousel
  @Local banners: Banner[] = []
  // classify
  @Local categories: CategoryItem[] = []
  // specialOffers
  @Local saleGoods: MkGoodsItem[] = []
  // explosiveRecommendation
  @Local hotGoods: MkGoodsItem[] = []
  // buyItAllInOneStop
  @Local oneGoods: MkGoodsItem[] = []
  // freshAndGood
  @Local newGoods: MkGoodsItem[] = []
  // recommendedProducts
  @Local lazyRecommendGoods: GoodsItemsDataSource<MkGoodsItem> = new GoodsItemsDataSource()
  @Consumer() navPath: NavPathStack = new NavPathStack()

  breakPoint: string = AppStorage.get(BreakPointConstants.CURRENT_BP) as string
  safeTop: number = AppStorage.get(SafeAreaConstants.TOP) as number
  page:number = 1
  // loading Effect state
  @Local isLoading: boolean = false
  @Local refresh: boolean = false
  @Builder refreshBuilder() {
    Row(){
      MkLoading()
    }
    .width('100%')
    .padding(10)
    .justifyContent(FlexAlign.Center)
  }
  async getData() {
    //waitForAllPromisesToResolve
    const resData = await Promise.allSettled([
      getBannerAPI(),
      getCategoryAPI(),
      getHotPreferenceAPI(),
      getHotInVogueAPI(),
      getHotOneStopAPI(),
      getNewAPI(),
      getRecommendAPI()
    ])
    //Throwing an exception prevents a crash caused by the inability to obtain data
    try {
      resData.forEach((item, index) => {
        if (item.status == 'fulfilled') {
          let data = item.value.data.result
          let hotData = data as HotResult
          let MkGoods =  data as MkGoodsItem[]
          //renderData
          if(index===0) this.banners = data as Banner[]
          if(index===1) this.categories = data as CategoryItem[]
          //There are suspicious bugs here, which can only be simplified to this extent for the time being
          if(index===2) this.saleGoods = hotData.subTypes[0].goodsItems.items
          if(index===3) this.hotGoods = hotData.subTypes[0].goodsItems.items
          if(index===4) this.oneGoods = hotData.subTypes[0].goodsItems.items
          //---------------------------------------------------------------
          if(index===5) this.newGoods = MkGoods
          if(index===6) this.lazyRecommendGoods.reloadData(MkGoods)
          AppStorage.setOrCreate('CategoryData',this.categories)
        }
      })
    } catch (e) {
      promptAction.showDialog({message:`${e}`})
    }
  }

  async refreshData() {
    //refresh is Direct Assignment
    await this.getData()
    this.refresh = false
    this.page = 1
  }
  //pullUpLoad


  async aboutToAppear() {
    //Displays loading animations before getting the data
    this.isLoading = true
    //get the Data Of The Server Response
    await this.getData()
    //hide loading
    this.isLoading = false
  }

  @Builder
  DiscountBuilder(params: Params) {

    Column() {
      Row({ space: 10 }) {
        Text(params.title)
          .fontColor($r('[basic].color.black'))
          .fontSize(14)
        Text(params.subTitle)
          .fontColor($r('[basic].color.text'))
          .fontSize(11)
      }
      .width('100%')
      .margin({ bottom: 10 })

      List({ space: 10 }) {
        ForEach(params.list, (item: MkGoodsItem) => {
          ListItem() {
            DiscountGoodsComp({ type: DiscountType.DISCOUNT, goods: item })
          }
        })
      }
      .width('100%')
      .height(116)
      .scrollBar(BarState.Off)
      .listDirection(Axis.Horizontal)
    }
    .height(160)
    .layoutWeight(1)
    .padding(10)
    .backgroundColor(params.bg)
    .borderRadius(8)
  }

  getSpace(): number | undefined {
    return new BreakPointType({ sm: 14, md: 36, lg: 72 }).getValue(this.breakPoint)
  }
  build() {
    if(this.isLoading){
      MkLoading()
    }else {
      Refresh({ refreshing:$$this.refresh,builder:this.refreshBuilder() }){
        Scroll() {
          Column() {
            // carousel and Search
            Stack({ alignContent: Alignment.Top }) {
              Swiper() {
                ForEach(this.banners, (item: Banner) => {
                  Image(item.imgUrl)
                })
              }
              .indicator(
                this.breakPoint === BreakPointConstants.SM ? DotIndicator.dot()
                  .itemWidth(8)
                  .itemHeight(4)
                  .color('#33191919')
                  .selectedItemWidth(24)
                  .selectedItemHeight(4)
                  .selectedColor('#191919') : false
              )
              .displayCount(
                new BreakPointType({ sm: 1, md: 2, lg: 3 })
                  .getValue(this.breakPoint)
              )
              .itemSpace(
                new BreakPointType({ sm: 0, md: 10, lg: 20 })
                  .getValue(this.breakPoint)
              )

              Row() {
                Row({ space: 4 }) {
                  Image($r('[basic].media.ic_public_search'))
                    .width(16)
                    .height(16)
                    .fillColor($r('[basic].color.white'))
                  Text('搜索...')
                    .fontSize(14)
                    .fontColor($r('[basic].color.white'))
                }
                .backgroundColor('#33191919')
                .width('100%')
                .height(40)
                .borderRadius(20)
                .padding({ left: 12 })
              }
              .padding({ left: 16, right: 16, top: this.safeTop })
              .onClick(()=>{
                this.navPath.pushPath({name:ViewsConstants.SEARCH_VIEW})
              })
            }
            .width('100%')


            // classify
            Column({ space: 10 }) {
              // classify
              List({ space: this.getSpace() }) {
                ForEach(this.categories, (item: CategoryItem) => {
                  ListItem() {
                    Column() {
                      Image(item.picture)
                        .width(56)
                        .aspectRatio(1)
                      Text(item.name)
                        .fontSize(10)
                        .fontColor('#CC191919')
                    }
                    .width(60)
                    .height(80)
                    .borderRadius(30)

                    .clip(true)
                    .backgroundImage(item.picture)
                    .backgroundImageSize(ImageSize.Contain)
                    .backgroundImagePosition(Alignment.Center)
                    .backgroundBlurStyle(
                      BlurStyle.BACKGROUND_ULTRA_THICK,
                      { scale: 0.25 }
                    )
                  }
                })
              }
              .width('100%')
              .height(92)
              .scrollBar(BarState.Off)
              .listDirection(Axis.Horizontal)
              .alignListItem(ListItemAlign.Center)

              // specialOffers
              Column({ space: 10 }) {
                Image($r('app.media.home_cmd_title'))
                  .width(150)
                  .height(20)
                Row() {
                  Image($r('app.media.home_cmd_inner'))
                    .width(86)
                    .height(116)
                  List({ space: this.getSpace() }) {
                    ForEach(this.saleGoods, (item: MkGoodsItem) => {
                      ListItem() {
                        DiscountGoodsComp({ goods: item })
                      }
                    })
                  }
                  .layoutWeight(1)
                  .width('100%')
                  .height(116)
                  .backgroundColor($r('[basic].color.white'))
                  .borderRadius({
                    topRight: 8,
                    bottomRight: 8
                  })
                  .padding({ right: 10, left: 10 })
                  .scrollBar(BarState.Off)
                  .listDirection(Axis.Horizontal)
                }
              }
              .width('100%')
              .height(166)
              .backgroundImage($r('app.media.home_cmd_sm'))
              .backgroundImageSize(ImageSize.Cover)
              .borderRadius(8)
              .padding(10)
              .alignItems(HorizontalAlign.Start)

              // explosiveRecommendation   buyItAllInOneStop
              Row({ space: 10 }) {
                this.DiscountBuilder({
                  title: '爆款推荐',
                  subTitle: '最受欢迎',
                  bg: '#EDF1FB',
                  list: this.hotGoods
                })
                this.DiscountBuilder({
                  title: '一站买全',
                  subTitle: '精心优选',
                  bg: '#FCF6EA',
                  list: this.oneGoods
                })
              }

              // freshAndGood
              Column({ space: 10 }) {
                Image($r('app.media.home_new'))
                  .width(146)
                  .height(19)
                List({ space: this.getSpace() }) {
                  ForEach(this.newGoods, (item: MkGoodsItem) => {
                    ListItem() {
                      DiscountGoodsComp({ type: DiscountType.NEW, goods: item })
                    }
                  })
                }
                .width('100%')
                .height(116)
                .scrollBar(BarState.Off)
                .listDirection(Axis.Horizontal)
              }
              .width('100%')
              .height(156)
              .padding(10)
              .backgroundColor('#F7EFF5')
              .borderRadius(8)
              .alignItems(HorizontalAlign.Start)

              // recommendedProducts
              MkWaterFlow({
                breakPoint: this.breakPoint,
                lazyRecommendGoods: this.lazyRecommendGoods,
                page: this.page
              })
            }
            .padding({
              left: 8,
              right: 8,
              bottom: 10,
              top: 10
            })
          }
        }
        .backgroundColor(Color.White)
        .scrollBar(BarState.Off)
        .transition(TransitionEffect.OPACITY.animation({duration:200}))
      }
      .transition(TransitionEffect.OPACITY.animation({duration:400}))
      .onRefreshing(()=>{
        this.refreshData()
      })
    }
  }
}