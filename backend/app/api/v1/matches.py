from fastapi import APIRouter

router = APIRouter()

@router.get("/")
async def get_matches():
    """Get potential matches for the user"""
    return {"message": "Get matches endpoint - to be implemented"}

@router.post("/swipe")
async def swipe():
    """Swipe left or right on a profile"""
    return {"message": "Swipe endpoint - to be implemented"}
