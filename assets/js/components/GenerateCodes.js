import React from 'react'
import { Card, FormLayout, TextField } from '@shopify/polaris'

export default ({
  pending,
  generate,
  changePrefix,
  prefix,
  changeCodeCount,
  codeCount,
}) => {
  return (
    <Card
      sectioned
      title="Generate discount codes"
      primaryFooterAction={{
        content: 'Generate',
        loading: pending,
        onClick: generate
      }}
    >
      <FormLayout>
        <FormLayout.Group>
          <TextField
            type="text"
            onChange={changePrefix}
            disabled={pending}
            value={prefix}
            placeholder="None"
            maxLength={20}
            label="Code prefix"
          />
          <TextField
            onChange={changeCodeCount}
            disabled={pending}
            type="number"
            value={codeCount}
            max={9999}
            min={0}
            label={
              <span>
                Number of discount codes <small className="small-label-info">(max. 9999)</small>
              </span>
            }
          />
        </FormLayout.Group>
      </FormLayout>
    </Card>
  )
}
