import React from 'react'
import { Banner } from '@shopify/polaris'

export default ({ onDismiss, onSet, pending }) => {
  return (
    <Banner
      onDismiss={onDismiss}
      action={{content: 'Set usage limit', onClick: onSet}}
    >
      <p>
        It seems you did not set a usage limit per code on the discount. Would you like to set it to "1"?
      </p>
    </Banner>
  )
}
