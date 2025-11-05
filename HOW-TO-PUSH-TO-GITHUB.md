# วิธี Push โปรเจคไป GitHub

## ขั้นตอนที่ 1: ตรวจสอบว่า Repository มีอยู่แล้วหรือไม่

1. ไปที่ https://github.com/patchalit/manus-personal-app
2. ถ้า Repository **ยังไม่มี** ให้สร้างใหม่:
   - ไปที่ https://github.com/new
   - Repository name: `manus-personal-app`
   - เลือก **Private**
   - **อย่า** เลือก "Initialize this repository with a README"
   - คลิก "Create repository"

## ขั้นตอนที่ 2: สร้าง Personal Access Token

1. ไปที่ https://github.com/settings/tokens
2. คลิก **"Generate new token (classic)"**
3. ตั้งค่า:
   - Note: `manus-app-push`
   - Expiration: `30 days`
   - เลือก scope: **repo** (ทั้งหมด)
4. คลิก **"Generate token"**
5. **คัดลอก Token ทันที** (จะแสดงครั้งเดียว)

## ขั้นตอนที่ 3: Push Code ไป GitHub

เปิด Terminal/Command Prompt แล้วรันคำสั่งเหล่านี้:

```bash
# 1. เข้าไปในโฟลเดอร์โปรเจค
cd path/to/manus_personal_app

# 2. ตรวจสอบว่ามี Git repository แล้ว
git status

# 3. ตั้งค่า remote (แทนที่ YOUR_TOKEN ด้วย Token ที่คัดลอกมา)
git remote remove origin
git remote add origin https://YOUR_TOKEN@github.com/patchalit/manus-personal-app.git

# 4. Push code
git push -u origin main
```

## ตัวอย่างคำสั่งที่สมบูรณ์

```bash
cd path/to/manus_personal_app
git remote remove origin
git remote add origin https://ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxx@github.com/patchalit/manus-personal-app.git
git push -u origin main
```

## ถ้าเกิดข้อผิดพลาด

### Error: "repository not found"
- ตรวจสอบว่าสร้าง Repository แล้ว
- ตรวจสอบชื่อ Repository ว่าถูกต้อง

### Error: "authentication failed"
- Token หมดอายุหรือไม่ถูกต้อง
- สร้าง Token ใหม่และลองอีกครั้ง

### Error: "remote origin already exists"
- รันคำสั่ง: `git remote remove origin`
- แล้วรันคำสั่ง add remote ใหม่

## หลังจาก Push สำเร็จ

1. ไปที่ https://github.com/patchalit/manus-personal-app
2. คุณจะเห็นไฟล์ทั้งหมดของโปรเจค
3. ตรวจสอบว่ามี commit message: "Phase 2: Initial Flutter project setup with models and services"

## ต้องการความช่วยเหลือ?

ถ้ายังมีปัญหา:
1. Screenshot ข้อความ error
2. ส่งให้ Manus ในเซสชันถัดไป
3. Manus จะช่วยแก้ไขให้

---

**หมายเหตุ:** 
- Token มีอายุ 30 วัน ควรบันทึกไว้ในที่ปลอดภัย
- อย่า commit Token เข้าไปใน repository
- ถ้า Token หลุด ให้ revoke ทันทีที่ https://github.com/settings/tokens
