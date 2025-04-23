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