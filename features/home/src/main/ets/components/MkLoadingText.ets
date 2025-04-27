@ComponentV2
export struct MkLoadingText {
  build() {
    Row({space:8}){
      LoadingProgress().height(30)
      Text('正在加载...').fontSize(20)
    }.width('100%').padding(12)
    .justifyContent(FlexAlign.Center)
  }
}
