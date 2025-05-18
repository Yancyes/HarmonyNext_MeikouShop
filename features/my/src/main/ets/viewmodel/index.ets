interface common {
  id: string
}

export interface OrderItem extends common {
  countdown: number;
  createTime: string;
  // 1 is to be paid, 2 is to be shipped, 3 is to be received, 4 is to be evaluated, 5 is completed, 6 is canceled, this parameter is not passed or 0 is all
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

export interface OrderSku extends common {
  attrsText: string;
  curPrice: number;
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

interface page {
  page: number
  pageSize: number
}

export interface GetOrderParams extends page {
  orderState: number
}

export interface GetOrderResult extends page {
  counts: number
  pages: number
  items: OrderItem[]
}