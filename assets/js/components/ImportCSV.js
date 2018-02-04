import React from 'react'
import ReactFileReader from 'react-file-reader'
import { Link, Tooltip, Icon, Button, Card, FormLayout, TextField } from '@shopify/polaris'
import {CSVLink} from 'react-csv'


const fileMessage = (csvFileName, codes) => {
  let message = ""

  if (!csvFileName) {
    message = "No file uploaded."
  } else if (codes && codes.length === 1) {
    message = `${csvFileName} (1 code)`
  } else if (codes && codes.length > 9999) {
    message = `${csvFileName} (truncated to 9999 codes)`
  } else if (codes) {
    message = `${csvFileName} (${codes.length} codes)`
  } else {
    message = `${csvFileName} is empty.`
  }

  return message
}

const exampleCSV = `firstCodeHere
secondCodeHere
thirdCodeHere
`

export default ({
  pending,
  importCSV,
  codes,
  uploadCSV,
  uploadingCSV,
  csvFileName,
}) => {
  return (
    <Card
      sectioned
      title="Import from CSV file"
      primaryFooterAction={{
        content: 'Import',
        loading: pending,
        disabled: !csvFileName || uploadingCSV,
        onClick: importCSV.bind(this, codes),
      }}
    >
        <div className="center">
          <div className="small-label-info csv-info">{fileMessage(csvFileName, codes)}</div>
          <ReactFileReader fileTypes={'.csv'} handleFiles={uploadCSV}>
            <Button loading={uploadingCSV} disabled={pending} size="slim">Upload CSV file</Button>
          </ReactFileReader>
          <div id="example-template-btn">
            <CSVLink filename="example.csv" data={exampleCSV} target="_blank">
              <Button plain>Example CSV file</Button>
            </CSVLink>
          </div>
        </div>
    </Card>
  )
}
