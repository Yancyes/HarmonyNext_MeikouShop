interface Common {
  id: string
  name: string
  picture: ResourceStr
}

interface title {
  title: string
}

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

export interface MkGoodsItem extends Common {
  desc: string
  price: string
  orderNum: number
}

export interface CategoryItem extends Common {
  children?: CategoryItemChild[]
  goods?: MkGoodsItem[]
}

export interface CategoryItemChild extends Common {
  children?: null
  goods?: null
}

export interface Banner extends Pick<Common, 'id'> {
  imgUrl: string
  type: string
  hrefUrl: string
}

export interface Params extends title {
  subTitle: string
  bg: ResourceStr
  list: MkGoodsItem[]
}

export interface HotResult extends title {
  id: string
  subTypes: SubType[]
}

export interface SubType {
  goodsItems: GoodsItems
  id: string
  title: string
}

export interface GoodsItems {
  counts: number
  items: MkGoodsItem[]
  page: number
  pages: number
  pageSize: number
}

export interface CartGoods extends Common {
  count: number
  price: number
  selected: boolean
  skuId: string
  stock: number
  attrsText: string
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
    this.picture = model.picture as string
    this.price = model.price
    this.selected = model.selected
    this.skuId = model.skuId
    this.stock = model.stock
    this.attrsText = model.attrsText
  }
}
