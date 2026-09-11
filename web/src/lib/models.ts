import raw from '../data/models.json';

export interface Quant {
  quant: string;
  vram: number;
  note: string;
  kvPerTokenMB?: number;
  context?: number;
}

export interface Recommended {
  quant: string;
  vram: number;
  kv8k: number;
}

export interface Kit {
  name: string;
  url: string;
  note: string;
}

export interface Model {
  id: string;
  name: string;
  family: string;
  category: string;
  params: string;
  paramsB: number;
  activeParamsB?: number | null;
  context: number;
  license: string;
  source: string;
  summary: string;
  why: string;
  fit: 'full' | 'tight' | 'offload' | string;
  recommended: Recommended;
  kvPerTokenMB: number | null;
  quants: Quant[];
  runtimes: Record<string, string>;
  kit?: Kit;
  tokps: string;
  released: number;
  tags: string[];
}

export interface Category {
  id: string;
  name: string;
  icon: string;
  blurb: string;
}

export interface Hardware {
  gpu: string;
  vramGB: number;
  usableVramGB: number;
  bandwidthGBs: number;
  ramGB: number;
  ramType: string;
  storage: string;
}

interface Dataset {
  meta: { name: string; tagline: string; target: string; version: string };
  hardware: Hardware;
  categories: Category[];
  models: Model[];
}

export const dataset = raw as unknown as Dataset;
export const models: Model[] = dataset.models;
export const categories: Category[] = dataset.categories;
export const hardware: Hardware = dataset.hardware;
export const meta = dataset.meta;

export const fitLabels: Record<string, string> = {
  full: 'Fits fully',
  tight: 'Tight fit',
  offload: 'Needs offload',
};

export const runtimeLabels: Record<string, string> = {
  exl3: 'ExLlamaV3 (EXL3)',
  ollama: 'Ollama',
  lmstudio: 'LM Studio',
  llamacpp: 'llama.cpp',
  vllm: 'vLLM / SGLang',
  comfyui: 'ComfyUI',
  other: 'Other',
};

export function byCategory(id: string): Model[] {
  return models.filter((m) => m.category === id);
}

export function byId(id: string): Model | undefined {
  return models.find((m) => m.id === id);
}

export function categoryById(id: string): Category | undefined {
  return categories.find((c) => c.id === id);
}

export function categoryName(id: string): string {
  return categoryById(id)?.name ?? id;
}

export const runtimeKeys: string[] = Array.from(
  new Set(models.flatMap((m) => Object.keys(m.runtimes ?? {})))
);

export function topPicks(ids: string[]): Model[] {
  return ids.map((id) => byId(id)).filter((m): m is Model => Boolean(m));
}
