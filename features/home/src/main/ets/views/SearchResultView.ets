import { BreakPointConstants, MkGoodsItem, SafeAreaConstants, ViewsConstants } from 'basic'
import { getRecommendAPI, searchGoodsAPI } from '../api'
import { MkLoadingText, MkWaterFlow } from '../components'
import { SearchParams, SortCompAttr, SortField, SortMethod } from '../viewmodel'
import { GoodsItemsDataSource } from '../viewmodel/lazyForeach'
import { promptAction } from '@kit.ArkUI'


@Builder
function SearchResultViewBuilder() {
  NavDestination() {
    SearchResultView()
  }
  .hideTitleBar(true)
}

@ComponentV2
export struct SearchResultView {
  safeTop: number = AppStorage.get(SafeAreaConstants.TOP) as number
  @Local dataLazy: GoodsItemsDataSource<MkGoodsItem> = new GoodsItemsDataSource()
  // queryParameters
  @Local
  params: SearchParams =
    {
      keyword: '',
      sortField: 'publishTime',
      sortMethod: 'asc',
      page: 1,
      pageSize: 10
    }
  // filterCriteria
  sortList: SortCompAttr[] = [
    { label: '时间', field: 'publishTime' },
    { label: '销量', field: 'orderNum' },
    { label: '价格', field: 'price' }
  ]
  scroller = new Scroller()
  @Consumer() navPath: NavPathStack = new NavPathStack()
  //used For Pagination Judgment
  pages: number = 1
  @Local isRefreshing: boolean = false

  async queryData() {
    const res = await searchGoodsAPI(this.params)
    this.dataLazy.reloadData(res.data.result.pageData.items)
    this.pages = res.data.result.pageData.pages
  }

  async loadMore() {
    if (this.params.page < this.pages) {
      //pageNumberIncreases
      this.params.page++
      const res = await searchGoodsAPI(this.params)
      this.dataLazy.pushDataArray(res.data.result.pageData.items)
    } else {
      promptAction.showToast({ message: '没有数据了~' })
    }
  }

  async getRecommendGoodsData() {
    const res = await getRecommendAPI()
    this.dataLazy.reloadData(res.data.result)
  }

  aboutToAppear() {
    // TODO parsingParameters
    this.params.keyword = this.navPath.getParamByName(ViewsConstants.SEARCH_RESULT_VIEW)[0] as string
    this.queryData()
  }

  @Monitor('params')
  paramsChange() {
  }

  @Builder
  refreshBuilder() {
    MkLoadingText()
  }

  build() {
    Column() {
      // searchArea
      Row() {
        Image($r('[basic].media.ic_public_left'))
          .width(24)
          .aspectRatio(1)
          .fillColor($r('[basic].color.white'))
          .margin(13)
          .onClick(() => {
            this.navPath.pop()
          })
        Search({ placeholder: '商品关键字...', value: this.params.keyword })
          .searchIcon({ src: $r('[basic].media.ic_public_search'), color: $r('[basic].color.gray') })
          .placeholderColor($r('[basic].color.gray'))
          .placeholderFont({ size: 14 })
          .backgroundColor($r('[basic].color.white'))
          .textFont({ size: 14 })
          .layoutWeight(1)
          .padding(0)
          .margin(0)
          .height(36)
          .caretStyle({ color: $r('[basic].color.red') })
          .onSubmit((value) => {
            this.params.keyword = value
            this.queryData()
          })
      }
      .padding({ top: this.safeTop, right: 16 })
      .linearGradient({
        angle: 135,
        colors: [[$r('[basic].color.linear_begin'), 0], [$r('[basic].color.linear_end'), 1]]
      })

      // list
      Row() {
        ForEach(this.sortList, (item: SortCompAttr) => {
          // filterComponents
          SortItemComp({
            label: item.label,
            field: item.field,
            sortField: this.params.sortField,
            sortMethod: this.params.sortMethod,
            onCLickItem: (sortField: SortField, sortMethod: SortMethod) => {
              this.params.sortField = sortField
              this.params.sortMethod = sortMethod
              this.queryData()
            }
          })
        })
        Text('筛选')
          .fontSize(14)
          .fontColor($r('[basic].color.gray'))
      }
      .padding({ left: 16, right: 16 })
      .height(50)
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .border({ width: { bottom: 0.5 }, color: $r('[basic].color.border') })

      // Goods Area
      Scroll() {
        Refresh({ refreshing: $$this.isRefreshing, builder: this.refreshBuilder() }) {
          MkWaterFlow({
            breakPoint: AppStorage.get(BreakPointConstants.CURRENT_BP) as string,
            page: this.params.page,
            lazyRecommendGoods: this.dataLazy
          })
        }.onRefreshing(async () => {
          //resetTheData
          this.getRecommendGoodsData()
          //resetThePageNumber
          this.params.page = 1
          this.queryData()
          this.isRefreshing = false
          promptAction.showToast({ message: '刷新成功',alignment:Alignment.Top,offset:{dy:200,dx:0} })
        })
      }.scrollBar(BarState.Off).layoutWeight(1)
    }
  }
}

@ComponentV2
struct SortItemComp {
  // filterFields
  @Param @Once field: SortField = 'publishTime'
  // theTextThatIsDisplayed
  @Param @Once label: string = ''
  @Param @Once sortField: SortField = 'publishTime'
  @Param @Once sortMethod: SortMethod = 'desc'
  // TODO Click on the filter criteria to pass back sortField and sortMethod to the parent component (callback function)
  @Param onCLickItem: (sortField: SortField, sortMethod: SortMethod) => void = () => {
  }

  build() {
    Row() {
      Text(this.label)
        .fontWeight(500)
        .fontSize(14)
        .fontColor(this.sortField === this.field ? $r('[basic].color.black') : $r('[basic].color.gray'))
      Column() {
        Image($r('[basic].media.ic_public_up'))
          .width(15)
          .height(6)
          .fillColor(this.sortField === this.field && this.sortMethod === 'asc' ? $r('[basic].color.black') :
          $r('[basic].color.gray'))
        Image($r('[basic].media.ic_public_down'))
          .width(15)
          .height(6)
          .fillColor(this.sortField === this.field && this.sortMethod === 'desc' ? $r('[basic].color.black') :
          $r('[basic].color.gray'))
      }
      .justifyContent(FlexAlign.Center)
    }
    .onClick(() => {
      if (this.field === this.sortField) {
        this.onCLickItem(this.field, this.sortMethod === 'desc' ? 'asc' : 'desc')
      } else {
        this.onCLickItem(this.field, 'desc')
      }
    })
  }
}