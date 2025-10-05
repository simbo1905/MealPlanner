# MealPlanner Agent Guidance

Based on [GitHub's Spec-Kit](https://github.com/github/spec-kit) specification-driven development framework, adapted for the MealPlanner project.

## Project Overview

MealPlanner is a **mobile-first service** that delights busy parents (personas: "Josh" and "Sonia") by solving real meal planning problems with the smallest viable solution, continuously validated through real-world user feedback.

## Core Philosophy

This project follows a **user-centered, lean-first approach**:
- Every feature starts with user discovery and validation
- Voice of User (VoU) feedback drives continuous improvement  
- Shortest Path to Value (SPTV) minimizes waste
- Evidence-based decisions over gut feelings
- Mobile-first, offline-capable architecture

## Workflow Commands

Follow these commands in order for each feature:

### 1. `/constitution` - Review Governing Principles
**Before any feature work**, review the constitutional principles:
- User-Centred Discovery
- Voice of the User (VoU) Continuous Feedback
- No Sunk Costs → Learn Fast Pivot Fast
- Lean-First, Shortest Path to Value (SPTV)
- Discovery-Alpha-Beta-Live Flow
- Evidence-Based Decision Making

📋 **Artifact**: [`.specify/memory/constitution.md`](.specify/memory/constitution.md)

### 2. `/specify` - Define "What & Why" (No Tech)
Create user stories and acceptance criteria **after** user research:
- Focus on Josh & Sonia's needs
- Include problem statements and opportunity maps
- Define measurable success criteria
- Mark any `[NEEDS CLARIFICATION]` gaps

📋 **Output**: `.specify/specs/<id>-<feature>/spec.md`

### 3. `/clarify` - Fill Knowledge Gaps (Optional)
Surface uncertainties before planning:
- User research gaps
- Technical unknowns  
- Success metric ambiguities
- Integration questions

### 4. `/plan` - Technical Architecture & Stack
**Only after validated user needs** are documented:
- Choose tech stack based on mobile-first requirements
- Design offline-first architecture
- Plan API contracts and data models
- Define performance budgets (<3s on 3G)
- Create Learning Log entry

📋 **Output**: `.specify/specs/<id>-<feature>/plan.md`
📋 **Output**: `.specify/specs/<id>-<feature>/research.md`
📋 **Output**: `.specify/specs/<id>-<feature>/data-model.md`
📋 **Output**: `.specify/specs/<id>-<feature>/contracts/`

### 5. `/tasks` - Generate Actionable Work Items
Create tasks that respect the "throw-away prototype" rule:
- Tests before implementation (TDD)
- User feedback integration points
- Mobile performance validation
- VoU ticket creation for tracking

📋 **Output**: `.specify/specs/<id>-<feature>/tasks.md`

### 6. `/analyze` - Cross-Artifact Consistency
Verify alignment across all artifacts:
- Does every task reference a Learning Log entry?
- Are VoU tickets created for user-facing changes?
- Do success metrics align with user validation criteria?
- Are mobile-first requirements addressed?

### 7. `/implement` - Build & Test
Execute tasks with continuous validation:
- Each step must close a VoU ticket or Learning Log item
- Deploy feedback widgets for user validation
- A/B test prototypes with real users
- Measure against success criteria

## Key Artifacts & Links

### Constitutional Documents
- **[Constitution](.specify/memory/constitution.md)** - Governing principles and standards
- **[Project Vision](#)** - Mobile-first meal planning for busy parents

### Feature Development Templates  
- **[Plan Template](.specify/templates/plan-template.md)** - Technical planning workflow
- **[Spec Template](.specify/templates/spec-template.md)** - User story specification
- **[Tasks Template](.specify/templates/tasks-template.md)** - Work breakdown structure

### Active Feature Specs
```
.specify/specs/
├── <id>-<feature>/
│   ├── spec.md          # User stories & acceptance criteria
│   ├── plan.md          # Technical architecture & decisions  
│   ├── tasks.md         # Implementation tasks
│   ├── research.md      # User research findings
│   ├── data-model.md    # Entity definitions
│   ├── contracts/       # API specifications
│   └── quickstart.md    # Validation procedures
```

## User-Centered Requirements

### Persona Alignment
- **Josh** (busy dad): Needs speed, simplicity, reliability
- **Sonia** (busy mom): Needs flexibility, family-friendly options, trust
- **Test**: "Would Josh/Sonia use this while juggling kids?"

### Success Metrics
- **NPS > 50** - Primary delight indicator
- **Task Success Rate > 80%** - End-to-end completion
- **<2 minutes** - Meal planning task completion
- **Statistical significance** (p<0.05) for A/B tests

### Mobile-First Constraints
- <3s load time on 3G networks
- Offline capability for core features
- 44px minimum touch targets
- Battery usage optimization
- Progressive Web App (PWA) capabilities

## Evidence-Based Development

### Required Documentation
- **Learning Log** - Decision rationale with user evidence
- **VoU Tickets** - User feedback tracking and response
- **Evidence Repository** - User research findings
- **Decision Log** - Major technical choices with justification

### Validation Process
1. **Discovery** - User research and problem definition
2. **Alpha** - Riskiest assumption testing with prototypes  
3. **Beta** - Limited pilot with real users
4. **Live** - Full deployment with monitoring
5. **Iterate/Retire** - Continuous improvement or removal

## Quality Gates

### Before Implementation
- [ ] User research completed and documented
- [ ] Success metrics defined and measurable
- [ ] VoU ticket created for tracking
- [ ] Mobile-first design validated
- [ ] Learning Log entry created

### Before Live Deployment  
- [ ] User feedback integration tested
- [ ] Performance budgets met
- [ ] Accessibility compliance verified
- [ ] Offline functionality validated
- [ ] Success criteria measurement ready

## Common Patterns

### Feature Development Flow
```
User Need → Discovery → Spec → Plan → Tasks → Implement → Validate → Iterate
```

### Feedback Integration
```
User Feedback → VoU Ticket → Triage → Implementation → Validation → Public Update
```

### Decision Making
```
Hypothesis → User Evidence → Decision Log → Implementation → Measurement → Learning
```

## Getting Help

- Review [constitution](.specify/memory/constitution.md) for principles
- Check artifact templates in [`.specify/templates/`](.specify/templates/)
- Follow the workflow sequence strictly
- Maintain user focus throughout development
- Document everything in Learning Logs

## Documentation Accountability

When writing documentation and/or code and/or any artefacts that touch disk, the following rules MUST BE FOLLOWED:
- **British English Professional Standards**: All published text follows en-GB spelling and business conventions
- **Quality Responsibility**: LLM processes user input and produces professionally transcribed documentation
- **Annotation System**: Only unclear or contradictory content is marked with `[TRANSCRIPTION NOTE: unclear/contradictory]`
- **Public Transparency**: Annotations make clear to GitHub viewers when content may reflect voice dictation artefacts
- **Universal Accountability**: LLM is responsible for all published text quality regardless of input method or role persona

## Memory and Decision Logging

### Memory Folder Structure
All comments, decisions, memory references, and constitution-required write-ups follow the same documentation standards and are stored in `./memory/` with dated sequential format:

```
./memory/
├── 2025-10-03_01.md  # First memory entry for date
├── 2025-10-03_02.md  # Second memory entry for date  
├── 2025-10-04_01.md  # First memory entry for next date
└── YYYY-MM-DD_NN.md  # General format: date_sequential-number
```

### Memory Entry Standards
- **Dated Format**: `YYYY-MM-DD_NN.md` with sequential numbering
- **Professional Format**: Clear structure with sections for context, decisions, rationale, and next actions
- **Decision Documentation**: Every decision must include user evidence, rationale, and implementation impact
- **Project Memory**: Technical challenges, UX insights, and strategic decisions preserved for future reference
- **Evidence Quality**: Source, method, confidence level, and coverage clearly documented

### When to Create Memory Entries
- User research sessions (like clarification interviews)
- Technical architecture decisions
- UX/Design strategy changes  
- Strategic pivots or scope modifications
- Constitution-required documentation (Learning Logs, decision rationales)
- Any "put that in project memory" requests from stakeholders

### Memory Entry Template
All memory entries follow professional British English standards with:
- Clear context and participant information
- Structured decision documentation with evidence
- Technical insights and project memory nuggets
- Quality assessment and next action items
- Transparent annotation for genuine ambiguities only

---
*This guidance implements the MealPlanner constitution v2.0.0 - user-centered, lean-first development for busy parents.*