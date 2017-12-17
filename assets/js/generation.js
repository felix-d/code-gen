import socket from './socket'

const CHANGE_CODE_COUNT = 'change_number_discount_codes'
const CHANGE_PREFIX = 'change_prefix'
const GENERATE = 'generate'
const PENDING = 'pending'
const COMPLETED = 'completed'
const READY = 'ready'
const ERROR = 'error'

const initialState = {
  status: READY,
  id: window.globals.priceRuleId,
  prefix: window.globals.priceRuleTitle.substring(0, 20),
  codeCount: 100,
  error: false,
}

export default (state = initialState, action) => {
  switch (action.type) {
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
