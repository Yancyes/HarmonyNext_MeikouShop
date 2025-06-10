import { emitter } from '@kit.BasicServicesKit'

export class BreakPointConstants {
  static readonly XS: string = 'xs' //watch
  static readonly SM: string = 'sm' //phone
  static readonly MD: string = 'md' //folding
  static readonly LG: string = 'lg' //tablet
}

export class ViewsConstants {
  static readonly SEARCH_VIEW: string = 'SearchView'
  static readonly SEARCH_RESULT_VIEW: string = 'SearchResultView'
  static readonly LOGIN_VIEW: string = 'LoginView'
  static readonly SETTING_VIEW: string = 'SettingView'
  static readonly GOODS_VIEW: string = 'GoodsView'
  static readonly CART_VIEW: string = 'CartView'
  static readonly CHECK_VIEW: string = 'CheckView'
  static readonly ADDRESS_MANAGE_VIEW: string = 'AddressManageView'
  static readonly ADDRESS_CREATE_VIEW: string = 'AddressCreateView'
  static readonly PAY_VIEW: string = 'PayView'
  static readonly PAY_RESULT_VIEW: string = 'PayResultView'
  static readonly ORDER_VIEW: string = 'OrderView'
  static readonly ORDER_LOGISTICS_VIEW: string = 'OrderLogisticsView'
}

export class EmitterKey {
  // switchToTheSpecifiedTab
  static CHANGE_TAB: emitter.InnerEvent = { eventId: 10001 }
}