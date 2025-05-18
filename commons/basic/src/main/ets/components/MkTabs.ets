export interface MkTabItem {
  name: string
  value?: string | number
}

@ComponentV2
export struct MkTabs {
  @Param @Once activeIndex: number = 0
  @Param tabConfig: MkTabItem[] = []
  @Param @Once lineWidth: number = 20
  @Param lineHeight: number = 2
  @Param tabHeight: number = 40
  @Param gutter: number = 20
  @Param paddingLeft: number = this.gutter
  @Param paddingRight: number = this.gutter
  @Local left: number = 0
  list: Area[] = []
  @Param @Once spaceBetween: boolean = false

  // cb
  @Event onTabClick?: (tab: MkTabItem, index: number) => void = () => { }

  @Event onTabChange?: (tab: MkTabItem, index: number) => void = () => { }

  // setsTheWidthAndPositionOfTheLine
  setLineLeft(area: Area) {
    // TODO
    this.lineWidth = area.width as number
    this.left = area.position.x as number
  }

  @Monitor('activeIndex')
  onActiveIndexChange() {
    this.setLineLeft(this.list?.[this.activeIndex])
  }

  @Builder
  TabBuilder(tab: MkTabItem, index: number) {
    Text(tab.name)
      .fontSize(15)
      .fontColor(this.activeIndex === index ? $r('app.color.black') : $r('app.color.gray'))
      .fontWeight(this.activeIndex === index ? 500 : 400)
      .animation({ duration: 300 })
      .onClick(() => {
        this.onTabClick?.(tab, index)
        if (this.activeIndex !== index) {
          this.activeIndex = index
          this.onTabChange?.(tab, index)
        }
      })
      .onAreaChange((_oldValue: Area, newValue: Area) => {
        this.list[index] = newValue
        if (this.activeIndex === index) {
          this.setLineLeft(newValue)
        }
      })
  }

  build() {
    Row() {
      Row({ space: this.gutter }) {
        ForEach(this.tabConfig, (item: MkTabItem, index) => {
          this.TabBuilder(item, index)
        })
      }
      .width('100%')
      .padding({ left: this.paddingLeft, right: this.paddingRight })
      .height(this.tabHeight)
      .border({
        width: { bottom: 0.5 },
        color: $r('app.color.under')
      })
      .justifyContent(this.spaceBetween ? FlexAlign.SpaceBetween : FlexAlign.Start)

      // movingLines
      Row()
        .width(this.lineWidth)
        .height(this.lineHeight)
        .backgroundColor($r('app.color.black'))
        .position({ x: this.left, y: this.tabHeight - this.lineHeight })
        .animation({ duration: 300 })
    }
    .layoutWeight(1)
  }
}