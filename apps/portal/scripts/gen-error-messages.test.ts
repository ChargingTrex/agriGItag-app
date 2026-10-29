/**
 * Tests the error-code table parser against the real docs/api/error-codes.md and a broken table.
 * Serves: plan §7.3 P00 (error-code mapper generated from docs/api/error-codes.md).
 * Called by: Vitest (`npm test`).
 */
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { describe, expect, it } from 'vitest';
import { parseErrorTable, renderModule } from './gen-error-messages.ts';

const markdown = readFileSync(
  resolve(import.meta.dirname, '../../../docs/api/error-codes.md'),
  'utf8',
);

describe('parseErrorTable', () => {
  it('reads every code with its Meaning column', () => {
    const rows = parseErrorTable(markdown);
    expect(rows).toContainEqual({
      code: 'validation_error',
      message: 'The request has invalid or implausible values.',
    });
    expect(rows.map((row) => row.code)).toContain('not_implemented_pilot');
  });

  it('fails loudly when the table format changes', () => {
    expect(() => parseErrorTable('| Name | Text |\n|---|---|\n| a | b |')).toThrow(/header/);
  });

  it('renders a module whose keys are the codes', () => {
    expect(renderModule([{ code: 'conflict', message: 'x "y"' }])).toContain(
      'conflict: "x \\"y\\"",',
    );
  });
});
