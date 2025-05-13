import { AddressItem, fullScreen, MkDialogLoading, MkNavbar, ViewsConstants } from 'basic';
import { createAddressAPI, editAddressAPI, RequestType } from '../apis';
import { promptAction } from '@kit.ArkUI';
import { geoLocationManager } from '@kit.LocationKit';

@Builder
function AddressCreateViewBuilder() {
  AddressCreateView()
}

// extendCustomStyles
@Extend(Row)
function listItemStyle() {
  .padding({ top: 4, bottom: 4 })
  .width('100%')
  .justifyContent(FlexAlign.SpaceBetween)
  .backgroundColor($r('[basic].color.white'))
}

@ComponentV2
export struct AddressCreateView {
  @Local safeBottom: number = fullScreen.init().bottomArea
  @Consumer() navPath: NavPathStack = new NavPathStack()
  // saveIDsDistinguishBetweenEditingAndAdding
  @Local addressId: string = ''
  @Local addressData: RequestType = {
    receiver: '', // consignee
    contact: '', // mobilePhoneNumber
    address: '', // fullAddress
    isDefault: 1, // 0 default 1 !default
  }

  dialog = new CustomDialogController({
    builder: MkDialogLoading(),
    customStyle: true,
  })

  aboutToAppear(): void {
    const data = this.navPath.getParamByName(ViewsConstants.ADDRESS_CREATE_VIEW).pop() as AddressItem
    if (data) {
      //formEchoes
      this.addressData = {
        receiver: data.receiver,
        contact: data.contact,
        address: data.address,
        isDefault: data.isDefault,
      }
      //saveTheAddress id
      this.addressId = data.id
    }
  }

  async onSubmit() {
    this.dialog.open()
    if(this.addressId){
      //modifyTheAddress
     const res = await editAddressAPI(this.addressId, this.addressData)
      promptAction.showToast({ message: res.data.msg })
      return
    }else {
      //added new delivery Address
      const res = await createAddressAPI(this.addressData)
      promptAction.showToast({ message: res.data.msg })
    }

    this.dialog.close()
    // backToThePreviousPage
    this.navPath.pop()
  }

  build() {
    NavDestination() {
      Column() {
        // topArea
        MkNavbar({
          title: this.addressId ? '编辑地址' : '新增地址',
        })

        // addressInformationForm
        Row() {
          List() {
            ListItem() {
              Row() {
                Text('收货人')
                  .width(80)
                  .fontSize(14)
                  .fontColor($r('[basic].color.black'))
                TextInput({ placeholder: '请填写收货人名称', text: $$this.addressData.receiver })
                  .fontSize(14)
                  .backgroundColor($r('[basic].color.white'))
              }
              .listItemStyle()
            }

            ListItem() {
              Row() {
                Text('手机号码')
                  .width(80)
                  .fontSize(14)
                  .fontColor($r('[basic].color.black'))
                TextInput({ placeholder: '请填写收货人电话', text: $$this.addressData.contact })
                  .fontSize(14)
                  .backgroundColor($r('[basic].color.white'))
              }
              .listItemStyle()
            }


            ListItem() {
              Row() {
                Text('详细地址')
                  .width(80)
                  .fontSize(14)
                  .fontColor($r('[basic].color.black'))
                TextInput({ placeholder: '请填写详细地址', text: $$this.addressData.address })
                  .fontSize(14)
                  .backgroundColor($r('[basic].color.white'))
                  .layoutWeight(1)
                LocationButton({
                  icon:LocationIconStyle.LINES
                }).backgroundColor(Color.White)
                  .iconColor(Color.Blue)
                  .onClick(async (event: ClickEvent, result: LocationButtonOnClickResult) => {
                    if (result === LocationButtonOnClickResult.SUCCESS) {
                      // Obtain temporary authorization to obtain authorization for location information
                      try {
                        // getTheCurrentLocationInformation
                        const location = await geoLocationManager.getCurrentLocation()
                        // Parse the geographic name based on the location information (only supported by real machines, M-chip Macs)
                        const res = await geoLocationManager.getAddressesFromLocation(location)
                        // theLocationIsDisplayedInTheForm
                        this.addressData.address = res[0].placeName || ''
                      } catch (error) {
                        // Handle the location error code and enable the location function in the control center
                        if (error.code === 3301100) {
                          promptAction.showToast({ message: '请开启定位开关~' })
                        }
                      }
                    } else {
                      promptAction.showToast({ message: '获取位置信息失败！' })
                    }
                  })
              }
              .listItemStyle()
            }

            ListItem() {
              Row() {
                Text('设为默认地址')
                  .fontSize(14)
                  .fontColor(($r('[basic].color.black')))
                Toggle({ isOn: this.addressData.isDefault === 0 ? true : false, type: ToggleType.Checkbox })
                  .selectedColor(($r('[basic].color.red')))
                  .onChange((isON) => {
                    this.addressData.isDefault = isON ? 0 : 1 //0 default 1 !default
                  })
              }
              .listItemStyle()
            }
          }
          .divider({
            strokeWidth: 1,
            color: '#eee'
          })
          .backgroundColor($r('[basic].color.white'))
          .padding({ left: 8, right: 8 })
        }
        .layoutWeight(1)
        .alignItems(VerticalAlign.Top)

        // saveButtonAtTheBottom
        Row() {
          Button('保存')
            .backgroundColor(($r('[basic].color.black')))
            .fontSize(14)
            .width('100%')
            .onClick(() => {
              this.onSubmit()
            })
        }
        .height(46)
        .padding({ left: 16, right: 16 })
      }
      .height('100%')
      .backgroundColor('#F5F4F9')
      .padding({ bottom: this.safeBottom })
    }
    .hideTitleBar(true)
  }
}

