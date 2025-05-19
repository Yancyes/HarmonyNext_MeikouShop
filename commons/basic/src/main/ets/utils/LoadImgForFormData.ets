import { formBindingData } from '@kit.FormKit'
import { Logger } from '..'
import { request } from '@kit.BasicServicesKit'
import { fileIo } from '@kit.CoreFileKit'

class FormData {
  //cardAddressArray
  fileNameList: string[]
  // cardInformation
  formImages: Record<string, string | number>

  constructor(fileNameList: string[], formImages: Record<string, string | number>) {
    this.fileNameList = fileNameList
    this.formImages = formImages
  }
}

export class LoadImageForFormData {
  // initialFormDataData
  initialFormData = new FormData([], {})
  // aListOfImagesToDownload
  private imageUrls: string[]
  // The function is executed after the image is downloaded
  private finishCb: (formInfo: formBindingData.FormBindingData) => void
  // currentAbility
  private abilityContext: Context
  // The image currently being downloaded is subscripted
  private curIndex: number = 0
  // localAddress
  private tempDir: string = ''
  // pictureObjectsInMemory
  private formImages: Record<string, string | number> = {}
  // aListOfTheNamesOfTheImageFiles
  private fileNameList: string[] = []

  /**
   *
   * @param abilityContext Context objects that access the global information of the application
   * @param imageUrls An array of image URLs to store the URLs of the image resources to be displayed
   * @param finishCb The completion callback function, which is called when the form data is submitted, is used to process the submitted data
   */
  constructor(
    abilityContext: Context,
    imageUrls: string[],
    finishCb: (formInfo: formBindingData.FormBindingData) => void,
  ) {
    // storesAnArrayOfImageURLs
    this.imageUrls = imageUrls
    // storeTheCompletionCallbackFunction
    this.finishCb = finishCb
    // storeContextObjects
    this.abilityContext = abilityContext
    // temporaryDirectoryCacheDirectory
    this.tempDir = abilityContext.getApplicationContext()
      .tempDir
  }

  addImage(imgUrl: string[]) {
    this.imageUrls = imgUrl
    return this
  }

  startLoad() {
    if (this.imageUrls.length === 0) {
      Logger.error('please provide download imglist')
      return
    }
    let netFile = this.imageUrls[this.curIndex]
    let fileName = 'file' + Date.now() + '.jpg'
    let tmpFile = this.tempDir + '/' + fileName
    request.downloadFile(this.abilityContext, {
      url: netFile, // Online address, specifying the online URL of the file to be downloaded
      filePath: tmpFile, // Where to save the file, specify the path to download the file to the local computer
      enableMetered: true, // Downloads are allowed on data-constrained networks, such as mobile data networks
      enableRoaming: true // downloadsAreAllowedOnRoamingNetworks
    }).then((task) => {
      task.on("complete", () => {
        try {
          // Open the downloaded image file based on the local path
          const file = fileIo.openSync(tmpFile)
          // saveTheFD Of The Open Picture File
          this.formImages[this.curIndex] = file.fd
        } catch (e) {
          console.error(`openSync failed: ${JSON.stringify(e)}`)
        }
        //saveThePictureInformation
        this.fileNameList.push(fileName)
        this.curIndex++
        if (this.curIndex < this.imageUrls.length) {
          //If you haven't finished downloading, continue downloading
          this.startLoad()
        } else {
          //allTheUpdatedDataHasBeenDownloaded
          this.initialFormData.fileNameList = this.fileNameList
          this.initialFormData.formImages = this.formImages
          // createDataTiedToTheCard
          let formInfo = formBindingData.createFormBindingData(this.initialFormData)
          // The packaged picture information is passed out through the callback function, so that the outside can accept it and pass it to the card
          this.finishCb(formInfo)
        }
      })
    }).catch(()=>{})
  }
}