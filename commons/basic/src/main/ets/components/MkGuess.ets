import { getGuessLikeApi, MkGoodsItem } from '..'
import { MkGoods } from './MkGoods'


@ComponentV2
export struct MkGuess {
  @Local likeGoods: MkGoodsItem[] = []
  @Local loading: boolean = false

  async aboutToAppear() {
    this.loading = true
    const res = await getGuessLikeApi()
    this.likeGoods = res.data.result.items
    this.loading = false
  }

  build() {
    Column() {
      Text('猜你喜欢')
        .fontSize(14)
        .fontWeight(500)
        .fontColor($r('app.color.black'))
        .width('100%')
        .height(50)
        .textAlign(TextAlign.Center)
        .backgroundColor($r('app.color.white'))
        .border({ width: { bottom: 0.5 }, color: $r('app.color.under') })
      if (this.loading) {
        Column() {
          Text('加载中...')
            .fontSize(14)
            .fontColor($r('app.color.gray'))
        }
        .height(400)
        .width('100%')
        .backgroundColor($r('app.color.white'))
        .padding({ top: 100 })
      } else {
        WaterFlow() {
          ForEach(this.likeGoods, (item: MkGoodsItem) => {
            FlowItem() {
              MkGoods({ goods: item, smallImage: true })
            }
          })
        }
        .columnsTemplate("1fr 1fr")
        .columnsGap(0.5)
        .rowsGap(0.5)
      }
    }
    .width('100%')
    .backgroundColor($r('app.color.under'))
  }
}