import React from 'react'
import { Banner } from '@shopify/polaris'
import { Link } from 'react-router-dom'
import { shop } from '../utils'

export default ({ discountId, codeCount }) => {
  return (
      <Banner
        id="success-banner"
        title={`Your ${codeCount} discount codes are ready!`}
        status="success"
      ><p>Click <a href={`https://${shop()}/admin/discounts/${discountId}/codes`} target="_parent">here</a> to see them in the admin.</p>
      </Banner>
  )
}
