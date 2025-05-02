@ComponentV2
export struct MkGuess {
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
    }
  }
}