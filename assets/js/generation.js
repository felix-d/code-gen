import socket from './socket'
import { filter } from 'lodash'

const CHANGE_CODE_COUNT = 'change_number_discount_codes'
const CHANGE_PREFIX = 'change_prefix'
const GENERATE = 'generate'
const PENDING = 'pending'
const COMPLETED = 'completed'
const READY = 'ready'
const ERROR = 'error'
const SELECT_TAB = 'select_tab'
const UPLOADING_CSV = 'uploading_csv'
const UPLOADED_CSV = 'uploaded_csv'

const initialState = {
  selectedTabIndex: 0,
  status: READY,
  id: window.globals.priceRuleId,
  prefix: window.globals.priceRuleTitle.substring(0, 20),
  codeCount: 100,
  error: false,
  csvFileName: null,
}

export default (state = initialState, action) => {
  switch (action.type) {
    case UPLOADING_CSV:
      return {
        ...state,
        uploadingCSV: true,
        status: READY,
      }
    case UPLOADED_CSV:
      return {
        ...state,
        uploadingCSV: false,
        csvFileName: action.name,
        codes: action.codes,
      }
    case SELECT_TAB:
      return {
        ...state,
        status: state.status === PENDING ? PENDING : READY,
        selectedTabIndex: action.index,
      }
    case ERROR:
      return {
        ...state,
        status: ERROR
      }
    case CHANGE_PREFIX:
      return {
        ...state,
        prefix: action.prefix,
        progress: null,
        status: READY,
      }
    case PENDING:
      return {
        ...state,
        status: PENDING,
        progress: action.progress,
        id: action.id,
        codeCount: action.codeCount,
      }
    case COMPLETED:
      return {
        ...state,
        status: COMPLETED,
        csvFileName: null,
        progress: null,
      }
    case CHANGE_CODE_COUNT:
      return {
        ...state,
        status: READY,
        progress: null,
        codeCount: action.count.substring(0, 4),
      }
    case GENERATE:
      return {
        ...state,
        progress: 0,
        status: PENDING,
      }
      break
    default:
      return state
  }
}

export function generate(count, prefix) {
  socket.push('generate', {
    count: parseInt(count),
    token: window.globals.token,
    id: window.globals.priceRuleId,
    prefix,
  })

  return {
    type: GENERATE,
    count,
  }
}

export function importCSV(codes) {
  const truncatedCodes = codes.slice(0, 9999)
  socket.push('generate', {
    codes: truncatedCodes,
    token: window.globals.token,
    id: window.globals.priceRuleId,
  })
  return {
    type: GENERATE,
    count: truncatedCodes.length,
  }
}

export function uploadCSV(files) {
  const file = files[0];

  return dispatch => {
    dispatch({
      type: UPLOADING_CSV,
    })

    const reader  = new FileReader()
    const startTime = Date.now()

    reader.onload = event => {
      const result = reader.result
      const codes = filter(result.split('\n'), code => code !== "")
      const minimumTime = 500
      const loadTime = Date.now() - startTime
      const difference = minimumTime - loadTime
      const extraWaitTime = difference < 0 ? 0 : difference

      setTimeout(function() {
        dispatch({
          type: UPLOADED_CSV,
          name: file.name,
          codes,
        })
      }, extraWaitTime);
    }

    reader.readAsText(file)
  }
}

export function changeCodeCount(count) {
  return {
    type: CHANGE_CODE_COUNT,
    count,
  }
}

export function changePrefix(prefix) {
  return {
    type: CHANGE_PREFIX,
    prefix,
  }
}

export function error() {
  return {
    type: ERROR,
  }
}

export function selectTab(index) {
  return {
    type: SELECT_TAB,
    index,
  }
}

export function pending({ progress, id, code_count: codeCount }) {
  if (progress < 1) {
    return {
      type: PENDING,
      progress: progress * 100,
      id,
      codeCount,
    }
  } else {
    return {
      type: COMPLETED,
    }
  }
}
