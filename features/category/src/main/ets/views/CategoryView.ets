import { BreakPointConstants, BreakPointType, CategoryItem, CategoryItemChild, MkNavbar, ViewsConstants } from 'basic'

@ComponentV2
export struct CategoryView {
  //  mock Classification Data
  categories: CategoryItem[] = AppStorage.get('CategoryData') as CategoryItem[]
  @Local activeIndex: number = 0
  breakpoint: string = AppStorage.get(BreakPointConstants.CURRENT_BP) as string
  scroller: Scroller = new Scroller()
  @Consumer() navPath: NavPathStack = new NavPathStack()
  build() {
    Column() {
      MkNavbar({
        title: '分类',
        showLeftIcon: false,
        showRightIcon: true,
        rightIcon: $r('[basic].media.ic_public_search'),
        rightClickHandler:()=>{
          this.navPath.pushPathByName(ViewsConstants.SEARCH_VIEW,null)
        }
      })
        .border({ width: { bottom: 0.5 }, color: $r('[basic].color.under') })

      Row() {
        Column() {
          ForEach(this.categories, (item: CategoryItem, i) => {
            Text(item.name)// text
              .backgroundColor(this.activeIndex === i ? $r('[basic].color.black') : $r('[basic].color.white'))
              .fontSize(14)
              .fontColor(this.activeIndex === i ? $r('[basic].color.white') : $r('[basic].color.black'))
              .textAlign(TextAlign.Center)
              .width('100%')
              .height(56)
              .onClick(() => {
                //synchronize Indexes
                this.activeIndex = i
                //when Switching Menus ScrollTo The Top
                this.scroller.scrollTo({ yOffset: 0, xOffset: 0, animation: true })
              })

          })
        }
        .width(88)
        .border({ width: { right: 0.5 }, color: $r('[basic].color.under') })

        Scroll(this.scroller) {
          Column() {
            // top Image
            Image(this.categories[this.activeIndex]?.picture)
              .width('100%')
              .height(new BreakPointType({ sm: 136, md: 200, lg: 220 })
                .getValue(this.breakpoint))
              .objectFit(ImageFit.Contain)
              .backgroundColor('#f6f6f6')
              .borderRadius(8)
              .margin({ bottom: 8 })
            //setTheNumberOfColumns
            GridRow({ columns: { sm: 2, md: 3, lg: 4 }, gutter: 8 }) {
              // sub categories
              ForEach((this.categories[this.activeIndex]?.children), (sub: CategoryItemChild) => {
                GridCol() {
                  Column() {
                    // picture
                    Image(sub.picture)
                      .width(64)
                      .aspectRatio(1)
                    Text(sub.name)// text
                      .fontSize(14)
                      .fontColor($r('[basic].color.text'))
                      .margin({ top: 8 })
                  }
                  .height('100%')
                  .justifyContent(FlexAlign.Center)
                }
                .aspectRatio(1)
                .backgroundColor('#f6f6f6')
                .borderRadius(8)
              })
            }
          }
          .padding(8)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .layoutWeight(1)
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .height('100%')
  }
}