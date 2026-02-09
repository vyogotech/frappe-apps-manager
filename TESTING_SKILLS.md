# Testing Skills Guide

This guide explains how to test skills on Claude Code, Cursor IDE, and Gemini CLI.

## Quick Test Checklist

- [ ] Skills are discoverable
- [ ] Skills can be invoked/activated
- [ ] Skills generate correct output
- [ ] Skills follow the expected patterns

## Testing on Claude Code

### 1. Verify Skills Are Loaded

```bash
# In Claude Code session
/help
```

Look for Frappe commands. If commands appear, skills are loaded.

### 2. Test Skill Auto-Invocation

Ask Claude to perform tasks that should trigger skills:

**Test DocType Builder:**
```
Create a Customer DocType with name, email, and phone fields
```

Expected: Claude should generate complete DocType JSON and controller files.

**Test API Handler:**
```
Create an API endpoint to get customer details by email
```

Expected: Claude should generate a whitelisted API method with proper validation.

**Test Report Generator:**
```
Create a sales analysis report grouped by customer
```

Expected: Claude should generate a query or script report with filters and charts.

### 3. Test Commands That Use Skills

```bash
/frappe-new-doctype
```

This command should use the `frappe-doctype-builder` skill internally.

### 4. Verify Skill Output Quality

Check that generated code:
- ✅ Follows Frappe conventions
- ✅ Includes proper error handling
- ✅ Has correct field types and permissions
- ✅ Matches the skill's documented patterns

## Testing on Cursor IDE

### 1. Verify Skills Are Discovered

1. Open Cursor IDE
2. Type `/` in Agent chat
3. You should see all 28 skills listed

### 2. Test Manual Skill Invocation

Type the skill name after `/`:

```
/frappe-report-generator
```

Then describe what you want:
```
Create a sales report for Q1 2024 with customer grouping
```

### 3. Test Auto-Selection

Ask the agent naturally:

```
Generate a DocType for Project Management with fields for name, start date, and status
```

The agent should automatically use `frappe-doctype-builder` skill.

### 4. Verify Skills Exist

```bash
# Check if skill files exist
ls .cursor/skills/*/SKILL.md | head -5

# Test reading a skill
head -10 .cursor/skills/frappe-report-generator/SKILL.md
```

Should show the skill content (YAML frontmatter with name and description).

## Testing on Gemini CLI

### 1. Enable Skills Feature

```bash
# Start interactive session
gemini

# Open settings
/settings

# Search for "Skills" and enable experimental feature
```

### 2. Verify Skills Are Discovered

```
/skills list
```

Should show all 28 skills with their descriptions.

### 3. Enable a Skill

```
/skills enable frappe-report-generator
```

### 4. Test Skill Activation

Ask Gemini to use the skill:

```
Create a sales report grouped by customer for the last quarter
```

Gemini should:
1. Show a consent prompt for skill activation
2. Activate the skill
3. Generate the report following the skill's patterns

### 5. Verify Skills Exist

```bash
# Check skill files
ls .gemini/skills/*/SKILL.md | head -5

# Test reading
head -10 .gemini/skills/frappe-report-generator/SKILL.md
```

## Comprehensive Test Scenarios

### Scenario 1: DocType Generation

**Test on all platforms:**

1. Request: "Create a Task DocType with title, description, status, and assignee fields"
2. Verify output includes:
   - Complete JSON definition
   - Python controller (if requested)
   - Proper field types
   - Permissions setup

**Expected Files:**
- `{app}/{module}/doctype/task/task.json`
- `{app}/{module}/doctype/task/task.py` (optional)

### Scenario 2: API Endpoint Creation

**Test on all platforms:**

1. Request: "Create an API to get task details by ID"
2. Verify output includes:
   - `@frappe.whitelist()` decorator
   - Proper error handling
   - Input validation
   - Response formatting

**Expected Code Pattern:**
```python
@frappe.whitelist()
def get_task_details(task_id):
    # Validation
    # Database query
    # Return formatted response
```

### Scenario 3: Report Generation

**Test on all platforms:**

1. Request: "Create a task status report with filters for date range"
2. Verify output includes:
   - Query or script report structure
   - Filter definitions
   - Column definitions
   - Chart configuration (if requested)

**Expected Files:**
- `{app}/{module}/report/task_status_report/task_status_report.json`
- `{app}/{module}/report/task_status_report/task_status_report.py`

### Scenario 4: Microservice Scaffolding

**Test on Cursor/Gemini (microservice skills):**

1. Request: "Scaffold a new microservice called inventory-service"
2. Verify output includes:
   - `server.py` with microservice setup
   - `Containerfile`
   - `entrypoint.py`
   - `requirements.txt`
   - Proper tenant isolation setup

## Testing Skill Quality

### Code Quality Checks

1. **Syntax**: Generated code should be valid Python/JSON
2. **Conventions**: Follows Frappe naming and structure conventions
3. **Completeness**: Includes all necessary components
4. **Error Handling**: Proper validation and error messages
5. **Documentation**: Comments where appropriate

### Pattern Adherence

Compare generated code against:
- Frappe core examples
- ERPNext patterns
- Skill documentation examples

### Token Efficiency

For optimized skills, verify:
- Output is concise but complete
- No unnecessary verbosity
- Pattern-based rather than example-heavy

## Debugging Failed Tests

### Skills Not Appearing

**Claude Code:**
- Check plugin is installed: `/plugin`
- Verify skills directory exists: `frappe-apps-manager/skills/`
- Restart Claude Code

**Cursor IDE:**
- Check skill files: `ls .cursor/skills/`
- Verify files have content: `head -5 .cursor/skills/frappe-doctype-builder/SKILL.md`
- Re-sync if needed: `./sync-skills.sh`

**Gemini CLI:**
- Verify skills are enabled: `/settings`
- Check skill files: `ls .gemini/skills/`
- Check config: `cat .gemini/config.json`
- Re-sync if needed: `./sync-skills.sh`

### Skills Not Invoking

1. **Check skill description**: Description should clearly state when to use
2. **Verify trigger words**: Use keywords from skill description
3. **Check skill format**: YAML frontmatter must be correct
4. **Review skill content**: Instructions should be clear

### Incorrect Output

1. **Review skill instructions**: Are they clear and complete?
2. **Check examples**: Do examples match expected output?
3. **Verify patterns**: Are patterns correct for Frappe?
4. **Test with simpler requests**: Narrow down the issue

## Automated Testing (Future)

### Test Script Structure

```bash
#!/bin/bash
# test-skills.sh

# Test skill discovery
test_discovery() {
    # Check if skills are found
}

# Test skill invocation
test_invocation() {
    # Test if skills are called correctly
}

# Test output quality
test_output() {
    # Validate generated code
}
```

### Integration Tests

Create test cases for:
- Each skill type
- Common use cases
- Edge cases
- Error scenarios

## Best Practices for Testing

1. **Test incrementally**: Start with one skill, then expand
2. **Use real scenarios**: Test with actual development needs
3. **Compare outputs**: Check against known good examples
4. **Document issues**: Keep track of problems and fixes
5. **Test across platforms**: Ensure consistency

## Quick Test Commands

### Claude Code
```bash
# In Claude Code
/help  # Verify commands appear
"Create a simple Customer DocType"  # Test auto-invocation
```

### Cursor IDE
```bash
# In Cursor Agent chat
/  # List skills
/frappe-doctype-builder  # Invoke skill
"Create a Customer DocType"  # Use skill
```

### Gemini CLI
```bash
gemini
/skills list  # List skills
/skills enable frappe-doctype-builder  # Enable skill
"Create a Customer DocType"  # Use skill
```

## Success Criteria

A skill is working correctly if:
- ✅ It's discoverable on the platform
- ✅ It can be invoked (manually or automatically)
- ✅ It generates correct, usable code
- ✅ Output follows Frappe conventions
- ✅ Code is complete and functional
- ✅ Error handling is present
- ✅ Documentation is clear

## Reporting Issues

When reporting skill issues, include:
1. Platform (Claude/Cursor/Gemini)
2. Skill name
3. Request made
4. Expected output
5. Actual output
6. Error messages (if any)
7. Platform version

## Next Steps

After testing:
1. Document any issues found
2. Update skill descriptions if needed
3. Refine skill instructions based on test results
4. Optimize token usage if output is too verbose
5. Add more examples if patterns aren't clear
