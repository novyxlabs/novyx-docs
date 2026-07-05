---
slug: /
title: "Novyx Docs — Change Control for AI Agents"
sidebar_position: 0
hide_title: true
description: "Govern AI agent actions before they touch production. Submit protected actions, classify risk, route approvals, audit decisions, and preserve recovery context."
---

# Novyx Documentation

Novyx is a change-control layer for AI agents touching production. Agents submit intended effects, Novyx evaluates policy and blast radius, returns `allowed`, `blocked`, or `pending_review`, and records the decision trail.

Memory, rollback, replay, and eval features still exist in the platform, but they support governance and incident review. They are not the main product promise.

<div style={{display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: '1rem', marginTop: '2rem'}}>

<a href="/getting-started/quickstart" style={{display: 'block', padding: '1.5rem', borderRadius: '0.75rem', border: '1px solid var(--ifm-toc-border-color)', textDecoration: 'none', color: 'inherit', transition: 'border-color 0.2s'}}>
  <h3 style={{margin: '0 0 0.5rem', color: 'var(--ifm-color-primary)'}}>Quickstart</h3>
  <p style={{margin: 0, fontSize: '0.875rem', opacity: 0.7}}>Submit a protected action and read the governance verdict.</p>
</a>

<a href="/api-reference/actions" style={{display: 'block', padding: '1.5rem', borderRadius: '0.75rem', border: '1px solid var(--ifm-toc-border-color)', textDecoration: 'none', color: 'inherit', transition: 'border-color 0.2s'}}>
  <h3 style={{margin: '0 0 0.5rem', color: 'var(--ifm-color-primary)'}}>Actions API</h3>
  <p style={{margin: 0, fontSize: '0.875rem', opacity: 0.7}}>Submit, evaluate, approve, block, and explain production-changing agent actions.</p>
</a>

<a href="/control/approval-workflows" style={{display: 'block', padding: '1.5rem', borderRadius: '0.75rem', border: '1px solid var(--ifm-toc-border-color)', textDecoration: 'none', color: 'inherit', transition: 'border-color 0.2s'}}>
  <h3 style={{margin: '0 0 0.5rem', color: 'var(--ifm-color-primary)'}}>Control</h3>
  <p style={{margin: 0, fontSize: '0.875rem', opacity: 0.7}}>Approval workflows, custom policies, dashboard metrics, and per-agent overrides.</p>
</a>

<a href="/mcp" style={{display: 'block', padding: '1.5rem', borderRadius: '0.75rem', border: '1px solid var(--ifm-toc-border-color)', textDecoration: 'none', color: 'inherit', transition: 'border-color 0.2s'}}>
  <h3 style={{margin: '0 0 0.5rem', color: 'var(--ifm-color-primary)'}}>MCP Server</h3>
  <p style={{margin: 0, fontSize: '0.875rem', opacity: 0.7}}>Use MCP as a path into governed actions, context, and audit evidence.</p>
</a>

<a href="/api-reference" style={{display: 'block', padding: '1.5rem', borderRadius: '0.75rem', border: '1px solid var(--ifm-toc-border-color)', textDecoration: 'none', color: 'inherit', transition: 'border-color 0.2s'}}>
  <h3 style={{margin: '0 0 0.5rem', color: 'var(--ifm-color-primary)'}}>API Reference</h3>
  <p style={{margin: 0, fontSize: '0.875rem', opacity: 0.7}}>REST reference for actions, audit, runtime, memory, replay, and support APIs.</p>
</a>

<a href="/sdks" style={{display: 'block', padding: '1.5rem', borderRadius: '0.75rem', border: '1px solid var(--ifm-toc-border-color)', textDecoration: 'none', color: 'inherit', transition: 'border-color 0.2s'}}>
  <h3 style={{margin: '0 0 0.5rem', color: 'var(--ifm-color-primary)'}}>SDKs</h3>
  <p style={{margin: 0, fontSize: '0.875rem', opacity: 0.7}}>Python, TypeScript, and CLI helpers for actions, memory, audit, and recovery workflows.</p>
</a>

</div>

---

**Base URL:** `https://novyx-ram-api.fly.dev`

**Current version:** v3.0.1 ([changelog](/changelog))

**Need help?** Join the [Discord](https://discord.gg/PCxZ3tMj) or email [support@novyxlabs.com](mailto:support@novyxlabs.com).
