import { FormIdManager, getGuessLikeApi, guessLike, LoadImageForFormData, MkGoodsItem, MkNavbar } from 'basic'
import { formBindingData, formProvider } from '@kit.FormKit'

@Builder
function RecommendViewBuilder() {
  RecommendView()
}

@ComponentV2
export struct RecommendView {
  @Consumer()
  navPath: NavPathStack = new NavPathStack()
  @Local
  list: MkGoodsItem[] = guessLike.init().items
  // carousel
  swiperController: SwiperController = new SwiperController()

  async getData(){
    const res = await getGuessLikeApi()
    this.list = res.data.result.items
    const imgUrls = this.list.map(item => item.picture as string).slice(0, 2)
    const downLoad = new LoadImageForFormData(
      getContext(),
      imgUrls,
      (formInfo: formBindingData.FormBindingData)=>{
        //getTheCardID
        const ids = FormIdManager.getFormIdList()
        //thereMayBeMoreThanOneCardUpdateAllCards
        ids.forEach(id=>{
          formProvider.updateForm(id, formInfo)
        })
      }
    )
    downLoad.startLoad()
  }
  build() {
    NavDestination() {
      Column() {
        Column() {
          this.topBanner()
          // carousel
          Column() {
            Swiper(this.swiperController) {
              ForEach(
                this.list,
                (item: MkGoodsItem) => {
                  Column() {
                    Image(item.picture)
                      .width('100%')
                    Text(item.name)
                      .margin({
                        top: 10
                      })
                      .fontSize(14)
                      .fontColor('#434343')

                    Text(`￥${item.price}`)
                      .margin({
                        top: 10
                      })
                      .fontSize(20)
                      .fontColor('#191919')
                      .fontWeight(700)
                  }
                  .padding(30)
                  .backgroundColor('#fff')
                }
              )
            }
            .width(270)
            .borderRadius(16)
            .indicator(
              new DotIndicator()
                .itemWidth(6)
                .itemHeight(6)
                .selectedItemWidth(6)
                .selectedItemHeight(6)
                .color('#E9E8EC')
                .selectedColor('#191919')
            )
          }
          .margin({
            top: -60
          })
        }
        .height('80%')
        .justifyContent(FlexAlign.Start)
        .linearGradient({
          angle: 180,
          colors: [
            ['#51E1F8', 0],
            ['#F5F4F9', 1]
          ]
        })

        Row() {
          Row() {
            Text('换一批看看')
              .fontSize(16)
              .fontColor('#fff')
          }
          .width('100%')
          .height(46)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#00C6C6')
          .onClick(() => {
            this.getData()
          })
        }
        .width('100%')
        .padding({
          left: 16,
          right: 16
        })
        .layoutWeight(1)
        .backgroundColor('#F5F4F9')
      }
    }
    .hideTitleBar(true)

  }

  @Builder
  topBanner() {
    Stack({ alignContent: Alignment.TopStart }) {
      Image($r("app.media.ic_public_hot_banner_bg"))
        .width('100%')
      MkNavbar({
        bg: Color.Transparent,
        leftClickHandler: () => {
          this.navPath.pop()
        }
      })
    }
  }
}