import { GoodsItems } from 'basic'

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
  id:string
  name:string
  picture:string
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

export type SortField = 'publishTime' | 'orderNum' | 'price'

export type SortMethod = 'desc' | 'asc'