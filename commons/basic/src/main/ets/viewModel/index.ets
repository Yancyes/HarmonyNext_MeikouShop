export interface MkGoodsItem {
  id: string
  name: string
  desc: string
  price: string
  picture: ResourceStr
  orderNum: number
}

export interface CategoryItem {
  children?: CategoryItemChild[]
  goods?: MkGoodsItem[]
  id: string
  name: string
  picture: ResourceStr
}

export interface CategoryItemChild {
  id: string
  name: string
  picture: ResourceStr
  children?: null
  goods?: null
}

export interface Banner {
  id: string;
  imgUrl: string;
  type: string;
  hrefUrl: string;
}


export interface Params {
  title: string,
  subTitle: string,
  bg: ResourceStr,
  list: MkGoodsItem[]
}

export interface HotResult {
  id: string;
  subTypes: SubType[];
  title: string;
}

export interface SubType {
  goodsItems: GoodsItems;
  id: string;
  title: string;
}

export interface GoodsItems {
  counts: number;
  items: MkGoodsItem[];
  page: number;
  pages: number;
  pageSize: number;
}

export interface CartGoods {
  count: number;
  id: string;
  name: string;
  picture: string;
  price: number;
  selected: boolean;
  skuId: string;
  stock: number;
  attrsText: string;
}

@ObservedV2
export class CartGoodsModel implements CartGoods {
  @Trace count: number = 0
  @Trace id: string = ''
  @Trace name: string = ''
  @Trace picture: string = ''
  @Trace price: number = 0
  @Trace selected: boolean = false
  @Trace skuId: string = ''
  @Trace stock: number = 0
  @Trace attrsText: string = ''

  constructor(model: CartGoods) {
    this.count = model.count
    this.id = model.id
    this.name = model.name
    this.picture = model.picture
    this.price = model.price
    this.selected = model.selected
    this.skuId = model.skuId
    this.stock = model.stock
    this.attrsText = model.attrsText
  }
}
