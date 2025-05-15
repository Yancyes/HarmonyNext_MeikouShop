export interface AddressItem {
  address: string
  contact: string
  fullLocation: string
  id: string
  isDefault: 0 | 1
  receiver: string
  provinceCode: number
  cityCode: number
  countyCode: number
}

export interface OrderGoodsItem {
  attrsText: string;
  count: number;
  id: string;
  name: string;
  payPrice: string;
  picture: string;
  price: string;
  skuId: string;
  totalPayPrice: string;
  totalPrice: string;
}

export interface Summary {
  discountPrice: number;
  goodsCount: number;
  postFee: number;
  totalPayPrice: number;
  totalPrice: number;
}

// billingInformation
export interface PreOrder {
  goods: OrderGoodsItem[]
  userAddresses: AddressItem[]
  summary: Summary
}

export interface CreateOrderParamsGoods {
  skuId: string
  count: number
}

export interface CreateOrderParams {
  deliveryTimeType: number
  payType: number
  buyerMessage: string
  payChannel: number
  goods: CreateOrderParamsGoods[]
  addressId: string
}

export interface CreateOrderResult {
  id: string
}

export interface OrderItem {
  countdown: number;
  createTime: string;
  id: string;
  orderState: 1 | 2 | 3 | 4 | 5 | 6;
  payChannel: number;
  payLatestTime: string;
  payMoney: number;
  payType: number;
  postFee: number;
  skus: OrderSku[];
  totalMoney: number;
  totalNum: number;
}

export interface OrderSku {
  attrsText: string;
  curPrice: number;
  id: string;
  image: string;
  name: string;
  properties: Property[];
  quantity: number;
  realPay: number;
  spuId: string;
}

export interface Property {
  propertyMainName: string;
  propertyValueName: string;
}