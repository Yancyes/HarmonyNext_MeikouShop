import { BreakPointConstants, MkNavPathStack, SafeAreaConstants } from 'basic'
import { CartView } from 'cart'
import { CategoryView } from 'category'
import { HomeView } from 'home'
import { MyView } from 'my'

interface TabItem {
  text: string
  normal: ResourceStr
  active: ResourceStr
}

@Entry
@ComponentV2
struct Index {
  @Local activeIndex: number = 0
  breakPoint: string = AppStorage.get(BreakPointConstants.CURRENT_BP) as string
  list: TabItem[] = [
    { text: '首页', normal: $r('app.media.ic_public_home_normal'), active: $r('app.media.ic_public_home_active') },
    { text: '分类', normal: $r('app.media.ic_public_pro_normal'), active: $r('app.media.ic_public_pro_active') },
    { text: '购物袋', normal: $r('app.media.ic_public_cart_normal'), active: $r('app.media.ic_public_cart_active') },
    { text: '我的', normal: $r('app.media.ic_public_my_normal'), active: $r('app.media.ic_public_my_active') },
  ]
  @Provider() navPath: NavPathStack = MkNavPathStack
  safeBottom: number = AppStorage.get(SafeAreaConstants.BOTTOM) as number

  build() {
    Navigation(this.navPath) {
      Tabs({ barPosition: BarPosition.End }) {
        ForEach(this.list, (item: TabItem, index: number) => {
          TabContent() {
            if (index === 0) {
              HomeView()
            } else if (index === 1) {
              CategoryView()
            } else if (index === 2) {
              CartView()
            } else {
              MyView()
            }
          }.tabBar(this.TabItemBuilder(item, index))
        })
      }
      .animationDuration(0)
      .scrollable(false)
      .onTabBarClick(index => {
        this.activeIndex = index
      })
      .barPosition(this.breakPoint === BreakPointConstants.LG ? BarPosition.Start : BarPosition.End)
      .vertical(this.breakPoint === BreakPointConstants.LG)
      .padding({ bottom: this.safeBottom })
    }.mode(NavigationMode.Stack)
    .hideTitleBar(true)
  }

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
}
