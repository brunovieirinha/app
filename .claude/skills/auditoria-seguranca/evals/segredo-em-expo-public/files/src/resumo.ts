import OpenAI from 'openai';
const client = new OpenAI({ apiKey: process.env.EXPO_PUBLIC_OPENAI_API_KEY });
export async function resumir(texto: string) {
  const r = await client.chat.completions.create({ model: 'gpt-4o-mini', messages: [{ role: 'user', content: texto }] });
  return r.choices[0].message.content;
}
