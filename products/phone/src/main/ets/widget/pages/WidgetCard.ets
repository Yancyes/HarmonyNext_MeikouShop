
const storage = new LocalStorage()

@Entry(storage)
@Component
struct WidgetCard {

  @LocalStorageProp('fileNameList') fileNameList: string[] = []
  // theDefaultCardIDIsEmpty
  @LocalStorageProp('formId') formId: string = ''
  build() {
    Column() {
      Row({space:10}) {
        Text('今日推荐')
          .fontColor('#fff')
          .fontSize(16)
        Image($r('app.media.ic_public_refresh'))
          .fillColor(Color.White)
          .width(30)
          .onClick(()=>{
            postCardAction(this, {
              action: 'call',
              abilityName: 'EntryAbility',
              params: {
                method: 'RefreshImgList',
                formId: this.formId
              }
            })
          })
      }
      .height(40)
      .width('100%').padding(5)
      .justifyContent(FlexAlign.Center)

      Row() {
        ForEach(
          this.fileNameList,
          (url: string) => {
            Row() {
              // TODO: 替换成从网络下载的图片
              // image Format Memory ImageName
              Image('memory://' + url)
                .borderRadius(12)
                .width(50)
                .aspectRatio(1)
            }
            .backgroundColor('#eee')
            .borderRadius(12)
          }
        )
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .layoutWeight(1)
      .padding({
        left: 20,
        right: 20
      })
      .backgroundColor('#fff')
      .borderRadius({
        topRight: 16,
        topLeft: 16
      })
      .onClick(() => {
        postCardAction(this, {
          action: 'router',
          abilityName: 'EntryAbility',
          params: { targetPage: 'RecommendView' }
        })
      })
    }
    .linearGradient({
      angle: '135',
      colors: [
        ['#FD3F8F', 0],
        ['#FF773C', 1]
      ]
    })
    .height('100%')
  }
}