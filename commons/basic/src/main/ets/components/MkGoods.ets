import { MkGoodsItem, MkNavPathStack, ViewsConstants } from '..'

@ComponentV2
export struct MkGoods {
  @Param goods: MkGoodsItem = {} as MkGoodsItem
  @Param smallImage: boolean = false
  @Param index: number = 0

  build() {
    Column({ space: 10 }) {
      if (this.smallImage) {
        Row() {
          img({ src: this.goods.picture, index: this.index })
        }
        .width('100%')
        .padding(20)
      } else {
        img({ src: this.goods.picture, index: this.index })
      }
      Text(this.goods.name)
        .fontSize(14)
        .fontColor($r('app.color.text'))
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .padding({ left: 10, right: 10 })
      Row({ space: 4 }) {
        Text('¥' + Number(this.goods.price))
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.black'))
        Text('¥999')
          .fontSize(8)
          .fontColor($r('app.color.gray'))
          .decoration({ type: TextDecorationType.LineThrough, color: $r('app.color.gray') })
        Blank()
        Text('2.9万+人付款')
          .fontSize(10)
          .fontColor($r('app.color.gray'))
      }
      .alignItems(VerticalAlign.Bottom)
      .width('100%')
      .margin({ bottom: 10 })
      .padding({ left: 10, right: 10 })
    }
    .width('100%')
    .backgroundColor($r('app.color.white'))
    .borderRadius(8)
    .clip(true)
    .onClick(() => {
      MkNavPathStack.pushPathByName(ViewsConstants.GOODS_VIEW, this.goods)
    })
  }
}

@ComponentV2
struct img {
  @Require @Param src: ResourceStr = ''
  @Require @Param index: number = 0

  build() {
    Image(this.src)
      .width('100%')
      .height(this.index % 2 ? 220 : 180)
  }
}