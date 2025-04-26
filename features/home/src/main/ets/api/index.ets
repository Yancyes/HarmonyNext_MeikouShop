import { Banner, CategoryItem, HotResult, Https, MkGoodsItem } from 'basic'
import { SearchParams, SearchResult } from '../viewmodel'

export const getBannerAPI = () => {
  return Https.get<Banner[]>('/home/banner')
}

export const getCategoryAPI = () => {
  return Https.get<CategoryItem[]>('/home/category/head')
}

export const getHotPreferenceAPI = () => {
  return Https.get<HotResult>('/hot/preference')
}

export const getHotInVogueAPI = () => {
  return Https.get<HotResult>('/hot/inVogue')
}

export const getHotOneStopAPI = () => {
  return Https.get<HotResult>('/hot/oneStop')
}

export const getNewAPI = () => {
  return Https.get<MkGoodsItem[]>('/home/new')
}

/**
 * @param limit the Amount Of Data Requested At Once
 * @default 8 */
export const getRecommendAPI = (limit: number = 8) => {
  return Https.get<MkGoodsItem[]>('/home/recommend', new Object({ limit }))
}
/**
 * @param data parameters For Submitting Data */
export const searchGoodsAPI = (data:SearchParams) => {
  return Https.post<SearchResult>('/search/all',data)
}