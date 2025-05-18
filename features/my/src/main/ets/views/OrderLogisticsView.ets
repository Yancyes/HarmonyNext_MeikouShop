import { map, mapCommon, MapComponent, navi } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { fullScreen } from 'basic';

@Builder
function OrderLogisticsViewBuilder() {
  OrderLogisticsView()
}


@ComponentV2
export struct OrderLogisticsView {
  @Local safeTop: number = fullScreen.init().topArea
  @Local safeBottom: number = fullScreen.init().bottomArea
  @Local loading: boolean = false
  @Consumer()
  navPath: NavPathStack = new NavPathStack()
  list: LogisticsItem[] = [
    {
      stateText: '运输中',
      detail: '您的订单已达到廊坊【美蔻北方仓库】',
      time: '昨天 16:34',
    },
    {
      stateText: '',
      detail: '您的订单已经离开天津武清分拣中心，前往美蔻北方仓库',
      time: '2024-06-09 12:34',
    },
    {
      stateText: '',
      detail: '您的订单由美蔻【天津武清分拣中心】准备送往【美蔻北方仓库】',
      time: '2024-06-09 10:21',
    },
    {
      stateText: '',
      detail: '您的订单由美蔻【天津武清分拣中心】分拣完成',
      time: '2024-06-09 08:10',
    },
    {
      stateText: '仓库处理中',
      detail: '打包完成',
      time: '2024-06-09 06:10',
    },
    {
      stateText: '',
      detail: '扫描完成',
      time: '2024-06-09 05:50',
    },
    {
      stateText: '',
      detail: '拣货完成',
      time: '2024-06-09 05:40',
    },
    {
      stateText: '',
      detail: '您的订单已打印完成',
      time: '2024-06-09 05:30',
    },
    {
      stateText: '已下单',
      detail: '温馨提示：您的订单预计6月10日09:00-15:00送达',
      time: '2024-06-09 06:10',
    },
  ]

  start: mapCommon.LatLng = {
    latitude: 22.641567,
    longitude: 113.923981
  }

  end: mapCommon.LatLng = {
    "latitude": 22.638014,
    "longitude": 113.942431
  }
  // stops
  currents: mapCommon.LatLng[] = [{
    "latitude": 22.630787,
    "longitude": 113.936783
  }]
  // mapRelated
  private mapOptions?: mapCommon.MapOptions
  private callback?: AsyncCallback<map.MapComponentController>
  private mapController?: map.MapComponentController
  private mapEventManager?: map.MapEventManager


  aboutToAppear(): void {
    this.initMap()
  }

  initMap() {
    // Map initialization parameters, set the coordinates and level of the map center point
    this.mapOptions = {
      position: {
        target: {
          longitude: (this.start.longitude + this.end.longitude) / 2,
          latitude: (this.start.latitude + this.end.latitude) / 2
        },
        zoom: 13
      }
    };

    // callbackForMapInitialization
    this.callback = async (err, mapController) => {
      if (!err) {

        this.mapController = mapController;

        let polylineOption: mapCommon.MapPolylineOptions = {
          points: [
            { longitude: 118.78, latitude: 31.975 },
            { longitude: 118.78, latitude: 31.982 },
            { longitude: 118.79, latitude: 31.985 },
            { longitude: 118.80, latitude: 31.978 },
            { longitude: 118.81, latitude: 31.981 },
            { longitude: 118.82, latitude: 31.984 },
            { longitude: 118.83, latitude: 31.977 },
            { longitude: 118.84, latitude: 31.980 },
            { longitude: 118.85, latitude: 31.983 },
            { longitude: 118.86, latitude: 31.976 }
          ],
          clickable: true,
          startCap: mapCommon.CapStyle.BUTT,
          endCap: mapCommon.CapStyle.BUTT,
          geodesic: false,
          jointType: mapCommon.JointType.BEVEL,
          visible: true,
          width: 10,
          zIndex: 10,
          gradient: false,
          color: 0xFFFF2737
        }
        // Marker
        let markerOptions: mapCommon.MarkerOptions = {
          position: this.start,
          rotation: 0,
          visible: true,
          zIndex: 0,
          alpha: 1,
          anchorU: 0.5,
          anchorV: 1,
          clickable: true,
          draggable: true,
          flat: false
        };
        // createAMarker
        await this.mapController.addMarker(markerOptions);
        // createAPolyline
        await this.mapController.addPolyline(polylineOption);
        const result = await this.testDrivingRoutes()
        // Logger.info(result.routes)
        result.routes[0].steps.forEach(step => {
          step.roads.forEach(road => {
            // road.polyline
            this.mapController?.addPolyline({
              points: road.polyline,
              clickable: true,
              startCap: mapCommon.CapStyle.BUTT,
              endCap: mapCommon.CapStyle.BUTT,
              geodesic: false,
              jointType: mapCommon.JointType.BEVEL,
              visible: true,
              width: 10,
              zIndex: 10,
              gradient: false,
              color: 0xFFFF2737
            });
          })
        })
      }
    };
  }
  // pathPlanning
  async testDrivingRoutes() {
    let params: navi.DrivingRouteParams = {
      // theLatitudeAndLongitudeOfTheStartingPoint
      origins: [this.start],
      // theLatitudeAndLongitudeOfTheEndPoint
      destination: this.end,
      // theRoutePointOfTheRoute
      waypoints: this.currents,
      language: "zh_CN"
    };
    return await navi.getDrivingRoutes(params);
  }
  build() {
    NavDestination() {
      Column() {
        Stack({ alignContent: Alignment.TopStart }) {
          if (!this.loading) {
            //  TODO theMapIsPlacedHere
            if (canIUse("SystemCapability.Map.Core")) {
              MapComponent({ mapOptions: this.mapOptions, mapCallback: this.callback })
                .width('100%').height('100%')
            }
          }
          Row() {
            Image($r('[basic].media.ic_public_left'))
              .width(24)
              .aspectRatio(1)
              .fillColor($r('[basic].color.text'))
          }
          .justifyContent(FlexAlign.Center)
          .width(40)
          .aspectRatio(1)
          .borderRadius(20)
          .backgroundColor($r('[basic].color.white'))
          .margin({ top: this.safeTop + 5, left: 16 })
          .onClick(() => {
            this.navPath.pop()
          })
        }
        .width('100%')
        .aspectRatio(1.2)

        Row({ space: 8 }) {
          Text('申通快递')
            .fontSize(12)
          Text('ST439742843428')
            .fontSize(12)
            .fontColor($r('[basic].color.gray'))
          Blank()
          Text('预计明天送达')
            .fontSize(12)
            .fontColor($r('[basic].color.gray'))
        }
        .padding({ left: 16, right: 16 })
        .height(40)
        .width('100%')
        .border({ width: { bottom: 0.5 }, color: $r('[basic].color.border') })

        List() {
          ForEach(this.list, (item: LogisticsItem, i) => {
            ListItem() {
              LogisticsItemComp({
                isActive: i === 0,
                isEnd: i === (this.list.length - 1),
                stateText: item.stateText,
                detail: item.detail,
                time: item.time
              })
            }
            .padding({ top: i === 0 ? 16 : 0 })
          })

        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Off)
      }
    }
    .hideTitleBar(true)

  }
}


interface LogisticsItem {
  stateText: string
  detail: string
  time: string
}

@ComponentV2
struct LogisticsItemComp {
  @Param stateText: string = ''
  @Param detail: string = ''
  @Param time: string = ''
  @Param isActive: boolean = false
  @Param isEnd: boolean = false

  build() {
    Row() {
      // indicator
      if (!this.isActive) {
        Row() {
        }
        .width(10)
        .height(10)
        .borderRadius(5)
        .backgroundColor('#E9E8EC')
        .position({ y: 6, x: -5 })
      } else {
        Row() {
          Image($r('[basic].media.ic_public_check'))
            .width(16)
            .aspectRatio(1)
            .fillColor($r('[basic].color.white'))
        }
        .justifyContent(FlexAlign.Center)
        .width(24)
        .aspectRatio(1)
        .backgroundColor($r('[basic].color.red'))
        .borderRadius(12)
        .position({ y: 0, x: -12 })
        .zIndex(1)
      }
      Row() {
      }
      .width(2)
      .height(this.isEnd ? 16 : '100%')
      .backgroundColor('#E9E8EC')
      .position({ y: 0, x: -1 })

      // info
      Column({ space: 6 }) {
        if (this.stateText) {
          Text(this.stateText)
            .fontSize(16)
            .fontWeight(500)
            .lineHeight(22)
            .fontColor(this.isActive ? $r('[basic].color.red') : $r('[basic].color.gray'))
        }
        Text(this.detail)
          .fontSize(14)
          .fontColor($r('[basic].color.text'))
        Text(this.time)
          .fontSize(12)
          .fontColor($r('[basic].color.gray'))
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .padding({ left: 20, bottom: 20 })
    }
    .width('100%')
    .padding({ left: 27, right: 16 })
    .clip(true)
  }
}