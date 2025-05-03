import { HmSku, HmSpec } from '@ohmos/sku'
import { GoodsItems, MkGoodsItem } from 'basic'

// parameters Submitted To TheServer
export interface SearchParams {
  keyword: string
  sortField: SortField
  sortMethod: SortMethod
  page: number
  pageSize: number
}

export interface Conditions {
  brands: Brand[]
  categories: null
}

export interface Brand {
  desc: null;
  logo: string;
  nameEn: string;
  place: null;
  type: null;
  id: string
  name: string
  picture: string
}

export interface SearchResult {
  // conditions: Conditions;
  pageData: GoodsItems;
}

// filterCriteria
export interface SortCompAttr {
  field: SortField
  label: string
}


export interface RouterParam {
  keyword: string
}

export interface GoodsProperty {
  name: string;
  value: string;
}

export interface GoodsDetail {
  pictures: string[];
  properties: GoodsProperty[];
}

export interface Goods extends MkGoodsItem {
  inventory: number
  mainPictures: string[]
  details: GoodsDetail
  specs: HmSpec[]
  skus: HmSku[]
}

export type SortField = 'publishTime' | 'orderNum' | 'price'

export type SortMethod = 'desc' | 'asc'