extends Node

# Grid width for layout
const GRID_WIDTH = 5

# Player data list
var player_data = [
	{"name": "מגיד השיעור", "category": "פוליטיקה", "color": Color.RED},
	{"name": "המלכה האם", "category": "פרחים", "color": Color.GREEN},
	{"name": "MP7", "category": "ציוד משרדי", "color": Color.VIOLET},
	{"name": "הראם המקורי", "category": "דגלים", "color": Color.YELLOW},
	{"name": "בומבלה", "category": "לוגואים", "color": Color.AQUA},
	{"name": "יעל", "category": "מוצרי איפור", "color": Color.GREEN_YELLOW},
	{"name": "הראם מעלי אקספרס", "category": "קבוצות כדורגל", "color": Color.ALICE_BLUE},
	{"name": "איתמר הנסיך", "category": "מכוניות", "color": Color.BURLYWOOD},
	{"name": "שורה בילה", "category": "פרטי לבוש", "color": Color.CORAL},
	{"name": "מוריה", "category": "מאכלים", "color": Color.CRIMSON},
	{"name": "אודי המושלמת", "category": "דמויות דיסני", "color": Color.DEEP_PINK},
	{"name": "לייבוש - סופר סתם", "category": "זמרים חסידיים", "color": Color.SPRING_GREEN},
	{"name": "הפראייר הגבוה", "category": "ערי בירה", "color": Color.AQUAMARINE},
	{"name": "אשתו של הראם המקורי", "category": "מוצרי אפייה", "color": Color.SEASHELL},
	{"name": "יודה", "category": "מאכלים מהעולם", "color": Color.GOLD},
	{"name": "שירה הבלתי מנוצחת", "category": "מוצרי תינוקות", "color": Color.PINK},
	{"name": "ישי ששון", "category": "השלמת פתגמים", "color": Color.LIGHT_CORAL},
	{"name": "הדסה האלופה", "category": "חפצים של בית", "color": Color.LIGHT_SKY_BLUE},
	{"name": "אילת ההורסת", "category": "מחירי מוצרים", "color": Color.PALE_GREEN},
	{"name": "איתן התותח", "category": "כלי נגינה", "color": Color.PURPLE},
]
