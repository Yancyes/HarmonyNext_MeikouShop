import { formBindingData, FormExtensionAbility, formInfo, formProvider } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { LoadImageForFormData } from 'basic';

const goodsList = [
  'http://yjy-xiaotuxian-dev.oss-cn-beijing.aliyuncs.com/picture/2021-04-05/6fdcac19-dd44-442c-9212-f7ec3cf3ed18.jpg',
  'https://yanxuan-item.nosdn.127.net/31a81e6c7e4c173d1cf19d5abeb97550.png'
]

export default class PhoneFormAbility extends FormExtensionAbility {
  onAddForm(want: Want) {
    // Called to return a FormBindingData object.
    if (want.parameters) {
      const formId = want.parameters['ohos.extra.param.key.form_identity'] as string
      //passTheIDToTheForm
      formProvider.updateForm(formId, formBindingData.createFormBindingData(
        new Object({ formId: formId }))
      )
      //downloadTheCardImageToolClass
      const downLoad = new LoadImageForFormData(this.context, goodsList,
        (formInfo: formBindingData.FormBindingData) => {
          formProvider.updateForm(formId, formInfo)
        })
      //start download
      downLoad.startLoad()
    }
    //returnTheFormData
    let formData = '';
    return formBindingData.createFormBindingData(formData);
  }

  onCastToNormalForm(formId: string) {
    // Called when the form provider is notified that a temporary form is successfully
    // converted to a normal form.
  }

  onUpdateForm(formId: string) {
    // Called to notify the form provider to update a specified form.
  }

  onFormEvent(formId: string, message: string) {
    // Called when a specified message event defined by the form provider is triggered.
  }

  onRemoveForm(formId: string) {
    // Called to notify the form provider that a specified form has been destroyed.
  }

  onAcquireFormState(want: Want) {
    // Called to return a {@link FormState} object.
    return formInfo.FormState.READY;
  }
}