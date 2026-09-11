export const BASE = import.meta.env.BASE_URL.replace(/\/+$/, '');

export function withBase(path = '/'): string {
  const p = path.startsWith('/') ? path : `/${path}`;
  return `${BASE}${p}`;
}

export const SITE = 'https://tespio.github.io';
export const REPO = 'https://github.com/tespio/moddle';
export const OLLAMA_URL = 'https://ollama.com';
