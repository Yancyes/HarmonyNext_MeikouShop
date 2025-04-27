import { BreakPointType, MkGoodsItem } from 'basic'
import { getRecommendAPI } from '../api'
import { GoodsItemsDataSource } from '../viewmodel/lazyForeach'
import { MkGoods } from './MkGoods'
import { promptAction } from '@kit.ArkUI'

@ComponentV2
export struct MkWaterFlow {
  @Require
  @Param breakPoint: string = ''
  @Require
  @Param @Once lazyRecommendGoods: GoodsItemsDataSource<MkGoodsItem> = new GoodsItemsDataSource()
  @Require @Param @Once page: number = 1

  async getMoreData() {
    this.page++
    //conditions For Loading More Data
    if (this.lazyRecommendGoods.totalCount() < 30) {
      const res = await getRecommendAPI(this.page * 8)
      this.lazyRecommendGoods.pushDataArray(res.data.result)
    } else {
      promptAction.showToast({ message: '没有数据了~' })
    }
  }

  build() {
    WaterFlow() {
      LazyForEach(this.lazyRecommendGoods, (item: MkGoodsItem) => {
        FlowItem() {
          MkGoods({ goods: item })
        }
      })
    }
    .columnsTemplate(
      new BreakPointType({
        sm: '1fr 1fr',
        md: '1fr 1fr 1fr',
        lg: '1fr 1fr 1fr 1fr'
      }).getValue(this.breakPoint)
    )
    .columnsGap(8)
    .rowsGap(10)
    .height('100%')
    .nestedScroll({
      scrollForward: NestedScrollMode.PARENT_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST
    })
    .onReachEnd(() => {
      this.getMoreData()
    })
  }
}