@ComponentV2
export struct MkCell {
  @Param label: string = ''
  @Param value: string = ''
  @Param icon: ResourceStr = $r('app.media.ic_public_right')
  @Param hasBorder: boolean = true
  @BuilderParam customLabel: () => void = this.LabelBuilder
  @BuilderParam customIcon: () => void = this.IconBuilder

  @Builder
  IconBuilder() {
    // icon
    Image(this.icon)
      .width(20)
      .aspectRatio(1)
      .fillColor($r('app.color.gray'))
  }

  @Builder
  LabelBuilder() {
    // text
    Text(this.label)
      .fontSize(14)
      .fontColor($r('app.color.black'))
  }

  build() {
    Row({ space: 8 }) {
      // text
      this.customLabel()
      Blank()
      Text(this.value)
        .fontSize(14)
        .fontColor($r('app.color.gray'))
      // icon
      this.customIcon()
    }
    .width('100%')
    .constraintSize({ minHeight: 50 })
    .border({ width: { bottom: this.hasBorder ? 1 : 0 }, color: $r('app.color.under') })
  }

}
