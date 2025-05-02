@ComponentV2
export struct MkCellGroup {
  @BuilderParam default: () => void = this.defaultBuilder

  @Builder
  defaultBuilder() {

  }

  build() {
    Column() {
      this.default()
    }
    .border({
      width: { top: 0.6, bottom: 0.6 },
      color: $r('app.color.under')
    })
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('app.color.white'))
  }
}