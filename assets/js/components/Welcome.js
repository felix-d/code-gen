import React from 'react'
import { Banner } from '@shopify/polaris'
import { shop } from '../utils'

export default () => {
  return (
    <Banner>
      <p>
        You can generate discount codes by clicking&nbsp;
        <strong>Generate discount codes</strong> from the&nbsp;
        <strong>More actions</strong> menu on any existing discount page.
      </p>
      <img id="example-image" src="images/example.png" alt="Example"/>
      <p>
        Start by <a target="_parent" href={`https://${shop()}/admin/discounts`}>selecting an existing discount</a>&nbsp;
        or <a target="_parent" href={`https://${shop()}/admin/discounts/new`}>creating a new discount</a>.
      </p>
    </Banner>
  )
}
