import { AddressItem, fullScreen, MkNavbar, ViewsConstants } from 'basic'
import { getAddressApi, setDefaultAddressAPI } from '../apis'

@Builder
function AddressManageViewBuilder() {
  AddressManageView()
}


@ComponentV2
export struct AddressManageView {
  @Local addressList: AddressItem[] = []
  @Local safeBottom: number = fullScreen.init().bottomArea
  @Consumer() navPath: NavPathStack = new NavPathStack()

  @Builder
  ActionBuilder(id: string) {
    Row() {
      Row() {
        Text('设为默认')
          .fontColor($r('[basic].color.white'))
          .fontSize(11)
          .padding({ left: 10, right: 10 })
      }
      .layoutWeight(1)
      .height('100%')
      .backgroundColor($r('[basic].color.black'))
      .onClick(async () => {
        await setDefaultAddressAPI(id)
        //update data
        this.getAddressList()
      })

      Row() {
        Text('删除')
          .fontColor($r('[basic].color.white'))
          .fontSize(11)
          .padding({ left: 10, right: 10 })
      }
      .backgroundColor($r('[basic].color.red'))
      .layoutWeight(1)
      .height('100%')
      .onClick(async () => {
        await setDefaultAddressAPI(id)
        //update data
        this.getAddressList()
      })
    }
    .width(88)
  }

  async getAddressList() {
    const res = await getAddressApi()
    this.addressList = res.data.result
  }

  build() {
    NavDestination() {
      Column() {
        // topArea
        MkNavbar({
          title: '收货地址管理',
          leftClickHandler: () => {
            this.navPath.pop()
          }
        })

        // listOfAddresses
        Row() {
          List() {
            ForEach(
              this.addressList,
              (item: AddressItem) => {
                ListItem() {
                  Row() {
                    Column() {
                      Row() {
                        // whetherItDefaultsOrNot
                        if (item.isDefault == 0) {
                          Row() {
                            Text('默认')
                              .fontSize(13)
                              .fontColor($r('[basic].color.white'))
                          }
                          .borderRadius(2)
                          .padding({
                            left: 8,
                            right: 8,
                            top: 2,
                            bottom: 2
                          })
                          .linearGradient({
                            angle: '93',
                            colors: [
                              [
                                '#FD3F8F',
                                0
                              ],
                              [
                                '#FF773C',
                                1
                              ]
                            ]
                          })
                          .margin({
                            right: 4
                          })
                        }

                        Text(item.address)
                          .fontColor('#434343')
                          .fontSize(14)

                      }

                      Text(`${item.receiver} ${item.contact}`)
                        .margin({ top: 8 })
                        .fontSize(12)
                    }
                    .alignItems(HorizontalAlign.Start)

                    Row() {
                      Image($r("app.media.ic_public_edit"))
                        .width(16)
                        .onClick(()=>{
                          //jumpAndPassTheParameters
                          this.navPath.pushPathByName(ViewsConstants.ADDRESS_CREATE_VIEW,item)
                        })
                    }
                  }
                  .padding(16)
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween)
                  .backgroundColor($r('[basic].color.white'))
                }
                .swipeAction({
                  end: this.ActionBuilder(item.id)
                })
                .margin({ bottom: 10 })
              }
            )
          }
          .width('100%')
          .height('100%')
        }
        .margin({ top: 8 })
        .padding({ left: 8, right: 8 })
        .layoutWeight(1)
        .alignItems(VerticalAlign.Top)

        // aNewAddressHasBeenAddedAtTheBottom
        Row() {
          Button('新增地址')
            .backgroundColor($r('[basic].color.black'))
            .fontSize(14)
            .width('100%')
            .onClick(() => {
              this.navPath.pushPath({ name: ViewsConstants.ADDRESS_CREATE_VIEW })
            })
        }
        .height(46)
        .padding({ left: 16, right: 16, })
      }
      .height('100%')
      .backgroundColor('#F5F4F9')
      .padding({ bottom: this.safeBottom })
    }
    .hideTitleBar(true)
    .onShown(() => {
      this.getAddressList()
    })
  }
}