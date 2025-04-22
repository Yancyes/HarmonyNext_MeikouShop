import { BreakPointConstants, BreakPointType } from 'basic'

interface TabItem {
  text: string
  normal: ResourceStr
  active: ResourceStr
}

@Entry
@ComponentV2
struct Index {
  @Local activeIndex: number = 0
  @Local breakPoint: string = AppStorage.get(BreakPointConstants.CURRENT_BP) as string
  list: TabItem[] = [
    { text: '首页', normal: $r('app.media.ic_public_home_normal'), active: $r('app.media.ic_public_home_active') },
    { text: '分类', normal: $r('app.media.ic_public_pro_normal'), active: $r('app.media.ic_public_pro_active') },
    { text: '购物袋', normal: $r('app.media.ic_public_cart_normal'), active: $r('app.media.ic_public_cart_active') },
    { text: '我的', normal: $r('app.media.ic_public_my_normal'), active: $r('app.media.ic_public_my_active') },
  ]

  @Builder
  TabItemBuilder(item: TabItem, index: number) {
    Column() {
      Image(this.activeIndex === index ? item.active : item.normal)
        .width(24)
        .aspectRatio(1)
      Text(item.text)// To access resources across HSPs, you need to import them in oh-package.json5
        .fontColor($r('[basic].color.black'))
        .fontSize(12)
    }
    .justifyContent(FlexAlign.SpaceEvenly)
    .height(50)
  }

  build() {
    Tabs({ barPosition: BarPosition.End }) {
      ForEach(this.list, (item: TabItem, index: number) => {
        TabContent() {

        }
        .tabBar(this.TabItemBuilder(item, index))
      })
    }
    .scrollable(false)
    .onTabBarClick(index => {
      this.activeIndex = index
    })
    //The item does not appear in the watch scene, so only 3 properties are needed
    .barPosition(new BreakPointType({
      sm: BarPosition.End,
      md: BarPosition.End,
      lg: BarPosition.Start
    }).getValue(this.breakPoint))
    .vertical(this.breakPoint === BreakPointConstants.LG)
  }
}